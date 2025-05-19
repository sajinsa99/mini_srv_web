#!/usr/bin/env bash

echo
echo "$(date '+%Y-%m-%d %H:%M:%S') - Début de l'exécution du script: $0"
echo

# Fonction pour récupérer la date de création (startdate) du certificat au format YYYY-MM-DD
get_pem_creation_date() {
    local domain="$1"local cert_fullchain_path cert_dir cert_path cert_startdate formatted_date

  # Si pas de domaine donné, prend le premier certificat certbot trouvé
  if [ -z "$domain" ]; then
      domain=$(/usr/bin/certbot certificates 2>/dev/null  | grep '^  Certificate Name:' | head -n1 | awk '{print $3}')
  fi

  if [ -z "$domain" ]; then
      echo "Erreur : aucun domaine trouvé via certbot certificates" >&2
      return 1
  fi

  # Récupérer le chemin du fullchain.pem pour ce domaine
  cert_fullchain_path=$(/usr/bin/certbot certificates 2>/dev/null | awk -v dom="$domain" '
  $0 ~ "Certificate Name: " dom {found=1}
  found && /Certificate Path:/ {
  print $NF
  exit
}
')

if [ -z "$cert_fullchain_path" ]; then
    echo "Erreur : certificat non trouvé pour le domaine $domain" >&2
    return 1
fi

cert_dir=$(dirname "$cert_fullchain_path")
cert_path="$cert_dir/cert.pem"

if [ ! -f "$cert_path" ]; then
    echo "Erreur : fichier cert.pem introuvable à $cert_path" >&2
    return 1
fi

cert_startdate=$(openssl x509 -in "$cert_path" -noout -startdate 2>/dev/null | cut -d= -f2)
if [ -z "$cert_startdate" ]; then
    echo "Erreur : impossible de récupérer la date de création du certificat" >&2
    return 1
fi

formatted_date=$(date -d "$cert_startdate" '+%Y-%m-%d' 2>/dev/null)
if [ -z "$formatted_date" ]; then
    echo "Erreur : impossible de convertir la date au format souhaité" >&2
    return 1
fi

echo "$formatted_date"
}

# Vérifie si l'option --force a été passée au script
FORCE_RENEWAL=false
for arg in "$@"; do
    if [ "$arg" == "--force" ]; then
        FORCE_RENEWAL=true
        break
    fi
done

# Récupérer la date d'expiration (expiry date)
#expiry_date=$(/usr/bin/certbot certificates 2>/dev/null | grep -i "Expiry Date" | awk -F: '{print $2":"$3":"$4}' | sed 's/^ *//g' | head -n1)
expiry_date=$(/usr/bin/certbot certificates 2>/dev/null | grep -i "Expiry Date" | head -n1 | awk -F: '{print $2}' | sed 's/^ *//g' | cut -d' ' -f1)


if [ -z "$expiry_date" ]; then
    echo "Erreur : impossible de récupérer la date d'expiration du certificat." >&2
    exit 1
fi

expiry_timestamp=$(date -d "$expiry_date" +%s)
current_timestamp=$(date +%s)

seconds_until_expiry=$((expiry_timestamp - current_timestamp))
days_until_expiry=$((seconds_until_expiry / 86400))

# Récupérer la date de création
startpemdate=$(get_pem_creation_date)
if [ $? -ne 0 ]; then
    echo "Erreur lors de la récupération de la date de création" >&2
    exit 1
fi

echo
echo "Date de création du certificat : $startpemdate"
echo "Date d'expiration : $expiry_date"
echo "Jours restants avant expiration : $days_until_expiry"
echo

if [ "$days_until_expiry" -le 2 ] || [ "$FORCE_RENEWAL" = true ]; then
    if [ "$FORCE_RENEWAL" = true ]; then
        echo "Option --force détectée, renouvellement forcé en cours..."
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Le certificat expire dans $days_until_expiry jours. Renouvellement en cours..."
    fi

    /usr/bin/certbot renew --quiet --force-renewal

    echo "$(date '+%Y-%m-%d %H:%M:%S') - Redémarrage de Nginx après renouvellement du certificat."
    /usr/bin/systemctl restart nginx
    /usr/bin/systemctl status nginx --no-pager

else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Le certificat n'expire pas dans 2 jours et l'option --force n'a pas été spécifiée. Aucune action nécessaire."
fi

echo
echo "$(date '+%Y-%m-%d %H:%M:%S') - Fin de l'exécution du script: $0"
echo

exit 0
