# 🚀 next-iga - Framework d'automatisation Robot

> **Framework Robot Framework + Playright pour tests fonctionnels automatisés**

## 📌 Introduction

Ce projet automatise des tests fonctionnels via Robot Framework et des ressources/bibliothèques Python locales. Il suit une architecture modulaire avec séparation des couches (étapes, pages, services, socle).

---

## 📂 Structure du projet (état réel)

Voici la structure détaillée des dossiers avec les explications :

```
next-iga/
│
├── 📄 README.md # Documentation du projet
├── 📄 robot.toml # Configuration extension Robocode
├── 📄 requirements.txt # Dépendances Python globales
├── 📄 settings.yml # Configuration d'exécution
├── 📄 .gitlab-ci.yml # Pipeline GitLab CI/CD
│
├── 📁 dataenv/ # Données de test et secrets
│ ├── 📄 INTEG_jdd.yml # Données pour l'environnement d'intégration (INTEG)
│ └── 🔒 secrets.kdbx # Gestionnaire de secrets (KeePass)
│
├── 📁 doc/ # Documentation HTML générée
│ └── 📄 *.html # Pages de doc Gherkin, hooks, etc.
│
├── 📁 outils/ # Scripts de lancement
│ ├── 📄 run_local.bat # Exécution locale (PRINCIPAL)
│ ├── 📄 build_doc.bat # Génération documentations
│ ├── 📄 build_local.bat # Build local
│ └── 📄 run_ci.sh # Exécution CI
│
├── 📁 output/ # Résultats d'exécution Robot
│ ├── 📄 report.html # Rapport visuel des tests
│ ├── 📄 log.html # Logs détaillés Robot
│ ├── 📄 output.xml # Résultats bruts (format Robot)
│ ├── 📄 StepsLogger.log # Logs step-by-step
│ ├── 📄 *.ndjson # Audits (ReporterLibrary)
│ ├── 📁 allure/ # Artefacts Allure
│ └── 📁 browser/ # Traces navigateur (Playwright)
│
├── 📁 src/ # Scripts de test -  source principal
│ │
│ ├── 📁 librairies/ # Bibliothèques Python custom
│ │ ├── 📄 ReporterLibrary.py # Génération audits NDJSON
│ │ ├── 📄 StepsLogger.py # Logs structurés step-by-step
│ │ └── 📄 *.py # Autres libs Python
│ │
│ ├── 📁 ressources/ # Ressources Robot Framework (keywords)
│ │ ├── 📁 socle/ # Couche de base partagée
│ │ │ ├── 📄 settings_socle.resource # Driver de la configuration
│ │ │ ├── 📄 dataset_socle.resource  # Driver des jeux de données
│ │ │ ├── 📄 vault_socle.resource    # Driver Keepass coffre-fort des secrets
│ │ │ └── 📁 playwright/
│ │ │   └─── 📄 web_socle.resource      # Driver Navigateurs
│ │ │
│ │ ├── 📁 etapes/ # Étapes métiers
│ │ ├── 📁 pages/ # Page Object Model
│ │ └── 📁 services/ # Services métier
│ │
│ └── 📁 test-suites/ # Suites de tests Robot
│ └── 📄 *.robot
│
└── 📁 .venv/ # Environnement virtuel Python
```

---

## ✅ Prérequis

<table>
<tr>
<td>🐍 Python</td>
<td><strong> 3.12</strong> - Assurez-vous d'avoir une version récente</td>
</tr>

<tr>
<td>🌐 Environnement Virtuel</td>
<td><code>run/.venv/</code> - Créé et activé automatiquement</td>
</tr>
</table>

---

## 🛠️ Installation

### Étape 1️⃣ - Activer l'environnement virtuel
```bash
run\.venv\Scripts\activate
```

### Étape 2️⃣ - Installer les dépendances
```bash
pip install -r ./lib/requirements.txt
```

---

## ▶️ Utilisation

### Lancer les tests
```bash
Usage: run_local.bat <TAG> [--web <selenium|playwright>] [--headless] [--history] [--env <env_name>]

Examples:
  run_local.bat smoke
  run_local.bat smoke --web selenium
  run_local.bat regression --browser edge --web playwright --env INTEG --headless --history
```

**Exemple :**
```bash
./run/start.bat smoke
```

### Lancer les tests en mode Headless (navigateur invisible)
```bash
./run/start.bat <TAG_DES_TESTS> --headless
```

**Exemple :**
```bash
./run/start.bat smoke --headless
```

### Lancer les tests en mode Dry Run (simulation du navigateur)
```bash
./run/start.bat <TAG_DES_TESTS> --dry-run
```

**Exemple :**
```bash
./run/start.bat smoke --dry-run
```

### Lancer les tests avec historisation des logs (horodatage des noms)
```bash
./run/start.bat <TAG_DES_TESTS> -history
```

**Exemple :**
```bash
./run/start.bat TsmokeNR --history
```

### Générer la documentation
```bash
./run/make_doc.bat
```

### Résultats et Rapports
Les résultats se trouvent dans `output/` :
- 📊 `report.html` - Rapport visuel des tests
- 📋 `log.html` - Logs détaillés d'exécution
- 📋 `output.xml` - Données brutes (Robot Framework)
- 📝 `StepsLogger.log` - Trace des étapes exécutées

---

## 🎯 Fonctionnalités Principales

### 🧪 Tests & Documentation
| Capacité | Description |
|---|---|
| 📖 **Documentation Auto** | Génération automatique de la doc à partir des tests |

### 🌐 Stack Technique Web
| Composant | Version/Détail |
|---|---|
| 🐍 **Python** | 3.12 |
| 🤖 **Robot Framework** | 7.4.1 |
| 🧪 **Browser Library** | 19.12.3 |

### 📦 Jeu de Données
| Feature | Détail |
|---|---|
| 📋 **Format YAML** | Externalisation complète des données de test |
| 🔒 **KeePass (kdbx)** | Gestionnaire de secrets sécurisé |
| 🔑 **Variables externalisées** | Pas de hardcoding des données |

### 🚀 Lancement & Supervision
| Aspect | Détail |
|---|---|
| ⚙️ **Configuration YAML** | Paramètres globaux centralisés YAML + secrets KeePass |
| 📝 **Logs normalisés** | Traces structurées par couche |
| 📊 **Audit NDJSON** | Format audit pour supervision/monitoring par exemple Grafana / InfluxDB / Fluentd |
| 📄 **Rapports HTML** | Report.html + log.html détaillés |

### 🏗️ Architecture
| Aspect | Détail |
|---|---|
| 🎯 **4 couches** | Tests → Steps → Services → Pages → Socle |
| 📦 **Modularité** | Ressources partagées et réutilisables |
| 🔄 **Page Object Model** | Maintenabilité et évolutivité |
| 🧩 **Couche socle** | Configuration, settings, vault, web_socle |
| 🌳 **Hiérarchie claire** | Séparation tests/métier/technique |

---

## 📚 Ressources Principales

### 🧪 Tests (Features)
Location: `test-suites/`
- Fichiers `.robot` au format Robot Framework
- Implémentation dans `ressources/etapes` en  `.resource` (Robot Framework)

### 🧩 Ressources Robot Partagées
Location: `ressources/socle/`
- Configuration globale et paramètres
- Utilitaires web et gestion des secrets
- Base commune pour tous les tests

### 🧩 Ressources Robot de l'application Web sous test
Location: `ressources/`
- `pages/` - Les actions possibles de chaque page
- `services/` - Enchainement des actions de page

  
### 🧩 Extension Python
Location: `librairies/`
- Fichiers `.py` au format Python
- `ReporterLibrary.py` - Génération des audits et des traces
- `StepsLogger.py` - Traces pour chaque keyword step, service, page, socle

### 📊 Données de Test
Location: `dataenv/`
- `INTEG_jdd.yaml` - Ensemble de données de test pour l'environnement INTEG
- `secrets.kdbx` - Gestionnaire de secrets sécurisé

### 🔄 Outils de lancement et de build
Location: `outils/`
- **`run_local.bat`** — Exécution locale des tests (PRINCIPAL)
  - Syntaxe : `run_local.bat <TAG> [--web selenium|playwright] [--browser edge|chrome|firefox] [--headless] [--history] [--env ENV_NAME]`
  - Exemples : `run_local.bat smoke`, `run_local.bat regression --env INTEG --headless`
  
- **`build_doc.bat`** — Génération de la documentation HTML
  - Génère les fichiers `.html` dans le répertoire `doc/`
  
- **`build_local.bat`** — Build local du projet
  - Installation du projet et de ses dependances
  
- **`run_ci.sh`** — Script d'exécution pour environnement CI (Linux/Bash)
  - Utilisé par GitLab CI/CD ou pipelines d'intégration continue (TODO/Work in progress)
---

## 🤝 Contribution

Les contributions sont les bienvenues ! 

1. Créez une branche pour votre feature
2. Commitez vos changements
3. Poussez vers la branche
4. Ouvrez une Pull Request

---

## 📞 Support

Pour toute question ou problème, veuillez ouvrir une issue ou contacter SOGETI/Jérôme BEAUMONT.


---

## Convention de nommage

# fichiers par typologie, variables, keywords, 