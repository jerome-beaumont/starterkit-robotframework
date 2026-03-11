# -*- coding: utf-8 -*-
"""Logger d'étapes pour Robot Framework, format ISO 8601 Z + couleurs ANSI."""

import sys
import os
import io
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn

# from robot.errors import RobotNotRunningError
from datetime import datetime, timezone

# Force UTF-8 si nécessaire et si buffer existe
if hasattr(sys.stdout, "buffer") and sys.stdout.encoding != "utf-8":
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")

# Couleurs ANSI
ANSI = {
    "blue": "\033[34m",
    "green": "\033[32m",
    "red": "\033[31m",
    "yellow": "\033[33m",
    "magenta": "\033[35m",
    "grey": "\033[90m",  # bright black
    "reset": "\033[0m",
}

# Emojis
EMOJI = {
    "test": "🧪",
    "etape": "➡️",
    "success": "✅",
    "error": "❌",
    "service": "🛠️",
    "page": "📄",
    "socle": "⚙️",
}

INDENT = {
    "test": "",
    "etape": "  ",
    "service": "    ",
    "page": "      ",
    "socle": "        ",
}

# Mapping (niveau + couleur) par catégorie
LEVELS = {
    "etape": ("INFO ", ANSI["blue"]),
    "success": ("INFO ", ANSI["green"]),
    "error": ("ERROR", ANSI["red"]),
    "service": ("INFO ", ANSI["magenta"]),
    "page": ("INFO ", ANSI["yellow"]),
    "socle": ("DEBUG", ANSI["grey"]),
    "test": ("INFO ", ""),  # couleur neutre (peut être bleue si souhaité)
}


class StepsLogger:
    """Lib Python pour Robot Framework.
    Options:
      - tz: 'UTC' ou 'LOCAL' (défaut: 'UTC')
      - ms3: bool, true => millisecondes sur 3 chiffres (.123), false => sans ms
      - color: bool, active la coloration console
      - emoji: bool, active les emojis (défaut: True mais désactivés en console Windows)
      - colored_console: bool, ajoute une ligne colorée explicite en console
         * Attention: Robot affiche déjà WARN/ERROR en console; colored_console=True
           ajoute une ligne supplémentaire (colorée). Mets False pour éviter le doublon.
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(
        self,
        tz: str = "UTC",
        ms3: bool = True,
        color: bool = True,
        emoji: bool = True,
        colored_console: bool = False,
    ):
        self.tz = tz.upper()
        self.ms3 = bool(ms3)
        self.color = bool(color)
        self.emoji = bool(emoji)
        self.colored_console = bool(colored_console)

        # Déterminer si on est sur Windows (qui ne supporte pas bien les emojis en console)
        import platform

        self.is_windows = platform.system() == "Windows"
        self.emoji_in_console = emoji and not self.is_windows

        # Initialiser le fichier de log
        try:
            output_dir = BuiltIn().get_variable_value("${OUTPUT DIR}")
            if not output_dir:
                output_dir = "."
        except Exception:
            output_dir = "."
        self.log_file_path = os.path.join(output_dir, "StepsLogger.log")

        # Vider le fichier de log au démarrage
        try:
            with open(self.log_file_path, "w", encoding="utf-8") as f:
                pass  # Fichier tronqué vide
        except Exception:
            pass  # Silencieusement ignorer les erreurs

    # ---------- helpers ----------
    def _timestamp_iso_z(self) -> str:
        # UTC ou LOCAL (inclut l'offset si LOCAL)
        if self.tz == "UTC":
            now = datetime.now(timezone.utc)
            if self.ms3:
                # %f => microsecondes (6 digits). On tronque à 3 pour ms.
                base = now.strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3]
                return f"{base}Z"
            else:
                return now.strftime("%Y-%m-%dT%H:%M:%SZ")
        else:
            now = datetime.now().astimezone()
            if self.ms3:
                base = now.strftime("%Y-%m-%dT%H:%M:%S.%f%z")
                return f"{base[:-5]}{base[-5:-3]}:{base[-3:]}"  # RFC3339 offset + ms
            else:
                base = now.strftime("%Y-%m-%dT%H:%M:%S%z")
                return f"{base[:-5]}{base[-5:-3]}:{base[-3:]}"  #  +hh:mm

    def _emit(
        self,
        category: str,
        msg: str,
        level: str,
        color_code: str,
        emoji_override: str = None,
        label_override: str = None,
    ):
        ts = self._timestamp_iso_z()
        emoji_sym = (
            emoji_override if emoji_override is not None else EMOJI.get(category, "")
        )
        label = label_override if label_override else category.upper()
        indent = INDENT.get(label.lower(), "")
        # logger.debug(f"label='{label}',category='{category}', indent='{indent}'; emoji='{emoji_sym}")

        # Message avec emojis (pour HTML et logs)
        msg_with_emoji = str(msg).encode("utf-8", errors="replace").decode("utf-8")
        file_line = (
            f"{ts} [{level}] {indent}"
            f"{(emoji_sym + ' ') if (self.emoji and emoji_sym) else ''}"
            f"{label}: {msg_with_emoji}"
        )

        # Message console SANS emojis sur Windows (pour éviter les ?)
        if self.emoji_in_console:
            console_line = file_line
        else:
            console_line = f"{ts} [{level}] {label}: {msg_with_emoji}"

        # Appliquer la couleur si activée
        if self.color and color_code:
            console_line = f"{color_code}{console_line}{ANSI['reset']}"

        # Écritures selon le niveau
        if level == "ERROR":
            logger.error(file_line)  # log + console automatique (RF)
            if self.colored_console:
                logger.console(console_line)
        elif level == "WARN":
            logger.warn(file_line)  # log + console automatique (RF)
            if self.colored_console:
                logger.console(console_line)
        elif level == "DEBUG":
            logger.debug(file_line)  # log uniquement
            if self.colored_console:
                logger.console(console_line)
        else:  # INFO / TRACE
            logger.info(file_line)  # log
            if self.colored_console:
                logger.console(console_line)
            else:
                # afficher aussi en console sans couleur
                logger.info(file_line, also_console=True)

        # Écrire dans le fichier de log
        self._write_to_log_file(file_line)

    def _write_to_log_file(self, line: str) -> None:
        """Écrit une ligne dans le fichier de log en UTF-8."""
        try:
            with open(self.log_file_path, "a", encoding="utf-8") as f:
                f.write(line + "\n")
        except Exception as e:
            # Silencieusement ignorer les erreurs d'écriture de log
            pass

    # ---------- API (keywords côté Robot) ----------
    def test(self, message: str):
        """🧪 TEST: … (INFO)."""
        level, color = LEVELS["test"]
        self._emit("test", message, level, color, EMOJI["test"], label_override="TEST")

    def etape(self, message: str):
        """➡️ ETAPE: … (INFO, bleu)."""
        level, color = LEVELS["etape"]
        self._emit("etape", message, level, color, EMOJI["etape"])

    def success(self, message: str, category: str = "ETAPE"):
        """✅ {category}: … (INFO, vert)."""
        level, color = LEVELS["success"]
        self._emit(
            "success",
            message,
            level,
            color,
            EMOJI["success"],
            label_override=category.upper(),
        )

    def error(self, message: str, category: str = "ETAPE"):
        """❌ ERROR: … (ERROR, rouge)."""
        level, color = LEVELS["error"]
        self._emit(
            "error",
            message,
            level,
            color,
            EMOJI["error"],
            label_override=category.upper(),
        )

    def service(self, message: str):
        """🛠️ SERVICE: {message} (INFO, magenta)."""
        level, color = LEVELS["service"]
        self._emit(
            "service", message, level, color, EMOJI["service"], label_override="SERVICE"
        )

    def page(self, message: str):
        """📄 PAGE: … (INFO, magenta)."""
        level, color = LEVELS["page"]
        self._emit("page", message, level, color, EMOJI["page"], label_override="PAGE")

    def socle(self, message: str):
        """⚙️ SOCLE: … (DEBUG, gris)."""
        level, color = LEVELS["socle"]
        self._emit(
            "socle", message, level, color, EMOJI["socle"], label_override="SOCLE"
        )

    # Modif des options à la volée
    def set_options(
        self,
        tz: str = None,
        ms3: bool = None,
        color: bool = None,
        emoji: bool = None,
        colored_console: bool = None,
    ):
        if tz is not None:
            self.tz = tz.upper()
        if ms3 is not None:
            self.ms3 = bool(ms3)
        if color is not None:
            self.color = bool(color)
        if emoji is not None:
            self.emoji = bool(emoji)
        if colored_console is not None:
            self.colored_console = bool(colored_console)
