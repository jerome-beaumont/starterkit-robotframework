*** Settings ***
Documentation     ACME - s'authentifier
...    *En tant que* utilisateur ACME
...    *Je souhaite* m'authentifier
...    *Afin* d'être connecté à mon compte

Resource    ${EXECDIR}/src/ressources/etapes/login_etape.resource
Test Template    L'utilisateur Valide De Profile "${profile}" Doit Être Connecté
Default Tags     smoke


*** Test Cases ***  PROFILE
Utilisateur avec profile "instructeur"  instructeur
Utilisateur avec profile "invité"       invité


*** Keywords ***
L'utilisateur Valide De Profile "${profile}" Doit Être Connecté
  [Documentation]  Voici la documentation du mot-clé.
  ...
  ...        Elle peut etre multi-lignes.

  Un Utilisateur Avec Le Profil "${profile}"
  L'Utilisateur S'Authentifie Avec Des Identifiants Valides
  L'Utilisateur Doit Être Connecté
