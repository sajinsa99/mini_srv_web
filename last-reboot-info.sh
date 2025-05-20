#!/usr/bin/env bash

# Recherche la date du dernier reboot dans journalctl du boot précédent
last_reboot_line=$(journalctl -b -1 --no-pager 2>/dev/null | grep -m1 'The system will reboot now!' || true)

if [[ -z "$last_reboot_line" ]]; then
    echo "La ligne 'The system will reboot now!' n'a pas été trouvée dans le journal du boot précédent."
    echo "Essai alternatif : date du dernier arrêt avec 'shutdown' dans journalctl..."

  # Autre tentative : chercher dans shutdown (peut marcher selon la config)
  last_reboot_line=$(journalctl -b -1 --no-pager 2>/dev/null | grep -m1 -i 'shutdown' || true)

  if [[ -z "$last_reboot_line" ]]; then
      echo "Impossible de trouver la date du dernier reboot dans le journal."
      exit 1
  fi
fi

# Extraire la date (exemple: May 20 21:39:52)
last_reboot_date=$(echo "$last_reboot_line" | awk '{print $1, $2, $3}')

# Convertir en timestamp Unix
last_reboot_ts=$(date -d "$last_reboot_date" +%s 2>/dev/null || echo 0)
if [[ "$last_reboot_ts" -eq 0 ]]; then
    echo "Impossible de convertir la date de reboot : $last_reboot_date"
    exit 1
fi

# Date du démarrage actuel (boot courant)
current_boot_line=$(journalctl -b --no-pager 2>/dev/null | head -n 1)
current_boot_date=$(echo "$current_boot_line" | awk '{print $1, $2, $3}')
current_boot_ts=$(date -d "$current_boot_date" +%s 2>/dev/null || echo 0)
if [[ "$current_boot_ts" -eq 0 ]]; then
    echo "Impossible de convertir la date du boot actuel : $current_boot_date"
    exit 1
fi

# Calculer durée reboot en secondes
reboot_duration=$(( current_boot_ts - last_reboot_ts ))

echo
echo "Dernier reboot enregistré : $last_reboot_date"
echo "Démarrage actuel : $(date -d @$current_boot_ts '+%Y-%m-%d %H:%M:%S')"
echo "Durée du reboot : $reboot_duration secondes ($(printf '%dh %dm %ds' $((reboot_duration/3600)) $(((reboot_duration%3600)/60)) $((reboot_duration%60))))"
echo "$(uptime -p)"
echo
exit 0
