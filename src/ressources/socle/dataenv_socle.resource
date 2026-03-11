*** Settings ***
Documentation       Obtenir les jeux de données pour les tests
...                 Basé sur un fichier YAML
...                 Fournit des mots-clés pour obtenir des utilisateurs en fonction de leur profil

Library         Collections
Resource        ${EXECDIR}/src/ressources/socle/settings_socle.resource

# Importer le fichier de jeux de données en fonction de l'environnement défini par la variable d'environnement MY_ENV 
#   ou si non défini depuis le settings, par exemple INTEG
Variables       ${EXECDIR}/dataenv/%{MY_ENV=${SETTINGS}[environment_default]}_jdd.yml


*** Keywords ***
Obtenir L'Url A Partir Du Site
  [Documentation]  Obtenir l'URL en fonction du canal (intradef, internet)
  [Arguments]  ${site}=${SETTINGS}[site_default]

  # Récupération de l'URL à partir du dictionnaire des urls en fonction du site demandé
  ${end_point}=  Get From Dictionary  ${urls}  ${site}

  RETURN  ${end_point}

Obtenir Un Utilisateur Avec Le Profil "${profil_utilisateur}"
  [Documentation]    Obtenir un jeu de données utilisateur en fonction du profil demandé
  ...
  ...    Paramètres :
  ...    - profil_utilisateur = ``le profil souhaité pour l'utilisateur`` (Obligatoire, pas de valeur défaut)
  ...
  ...    Exemples :
  ...    | Obtenir Un Utilisateur Avec Le Profil "Usager"    | _--> Retourne le premier utilisateur avec le profil Usager _ |
  ...    | Obtenir Un Utilisateur Avec Le Profil "Instructeur" | _--> Retourne le premier utilisateur avec le profil Instructeur _ |
  ...
  ...    ---

  StepsLogger.Socle  Obtenir un jeu de données utilisateur avec le profil "${profil_utilisateur}"...
  # Itérer sur la liste des utilisateurs pour trouver le premier avec le profil demandé
  VAR  ${found_user}=  ${None}
  FOR  ${user}  IN  @{utilisateurs}
    IF  '${user}[profile]' == '${profil_utilisateur}'
      VAR  ${found_user}=  ${user}
      BREAK
    END
  END
  IF  ${found_user} is ${None}
    Fail  Aucun utilisateur trouvé avec le profil "${profil_utilisateur}"
  END
  StepsLogger.Success  Utilisateur trouvé : ${found_user}

  RETURN  ${found_user}
