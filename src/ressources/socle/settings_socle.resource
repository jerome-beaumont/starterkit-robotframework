*** Settings ***
Documentation  Obtenir les éléments de configuration pour les tests
...            Basé sur un fichier YAML
...            Charge également les librairies pour la gestion des logs et des étapes

Library     Collections
Library     ${EXECDIR}/src/librairies/ReporterLibrary.py
Library     ${EXECDIR}/src/librairies/StepsLogger.py


*** Variables ***
# Dictionnaire des paramètres globaux importer à l'exécution via --variablefile
&{SETTINGS}     &{EMPTY}

