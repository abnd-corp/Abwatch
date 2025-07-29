#!/bin/bash

# Vérifie si ~/.local/bin est dans le PATH, sinon l'ajoute temporairement
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# Fonction pour vérifier si un programme est installé
check_dep() {
  command -v "$1" >/dev/null 2>&1
}

# Fonction pour télécharger trivy
install_trivy() {
  echo "⬇️  Téléchargement de trivy..."
  mkdir -p "$HOME/.local/bin"
  local url="https://github.com/aquasecurity/trivy/releases/latest/download/trivy_$(uname -s)_$(uname -m)"
  curl -sfL "$url" -o "$HOME/.local/bin/trivy" && chmod +x "$HOME/.local/bin/trivy"
  if [ $? -eq 0 ]; then
    echo "✅ trivy installé dans ~/.local/bin"
  else
    echo "❌ Échec de l'installation de trivy. Veuillez l'installer manuellement."
  fi
}

# Fonction pour télécharger dockle
install_dockle() {
  echo "⬇️  Téléchargement de dockle..."
  mkdir -p "$HOME/.local/bin"
  local version="0.6.22"
  local url="https://github.com/goodwithtech/dockle/releases/download/v0.4.15/dockle_0.4.15_Linux-64bit.tar.gz"
  
  # Téléchargement + extraction
  curl -sfL "$url" -o /tmp/dockle.tar.gz
  if [ $? -ne 0 ]; then
    echo "❌ Échec du téléchargement de dockle."
    return
  fi

  tar -xzf /tmp/dockle.tar.gz -C /tmp
  if [ $? -ne 0 ]; then
    echo "❌ Échec de l'extraction de dockle."
    return
  fi

  mv /tmp/dockle "$HOME/.local/bin/dockle"
  chmod +x "$HOME/.local/bin/dockle"
  rm /tmp/dockle.tar.gz

  echo "✅ dockle installé dans ~/.local/bin"
}

# Vérification des dépendances
echo "🔍 Vérification des dépendances..."

missing=()

if ! check_dep trivy; then
  echo "❌ trivy est manquant"
  missing+=("trivy")
else
  echo "✅ trivy est installé"
fi

if ! check_dep dockle; then
  echo "❌ dockle est manquant"
  missing+=("dockle")
else
  echo "✅ dockle est installé"
fi

if [ ${#missing[@]} -gt 0 ]; then
  echo -e "\n⚠️  Il manque les dépendances suivantes :"
  for dep in "${missing[@]}"; do
    echo "   - $dep"
  done

  read -p "Souhaitez-vous les télécharger maintenant ? (y/n) " answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    for dep in "${missing[@]}"; do
      case $dep in
        trivy) install_trivy ;;
        dockle) install_dockle ;;
      esac
    done
  else
    echo "⏩ Installation annulée. Sortie du script."
    exit 1
  fi

  # Re-vérifier après installation
  echo -e "\n🔍 Re-vérification des dépendances après installation..."
  still_missing=()
  for dep in "${missing[@]}"; do
    if ! check_dep "$dep"; then
      still_missing+=("$dep")
    fi
  done

  if [ ${#still_missing[@]} -gt 0 ]; then
    echo "❌ Certaines dépendances n'ont pas pu être installées :"
    for dep in "${still_missing[@]}"; do
      echo "   - $dep"
    done
    echo "Veuillez les installer manuellement."
    exit 1
  fi
fi

# Vérifier si ~/.local/bin est dans le PATH de façon permanente
if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc 2>/dev/null && \
   ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.zshrc 2>/dev/null; then
  read -p "Voulez-vous ajouter ~/.local/bin à votre PATH de façon permanente ? (y/n) " addpath
  if [[ "$addpath" =~ ^[Yy]$ ]]; then
    if [ -f ~/.bashrc ]; then
      echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
      echo "✅ Ajouté dans ~/.bashrc"
    elif [ -f ~/.zshrc ]; then
      echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
      echo "✅ Ajouté dans ~/.zshrc"
    else
      echo "⚠️ Aucun fichier bashrc ou zshrc trouvé. Ajoutez manuellement :"
      echo 'export PATH="$HOME/.local/bin:$PATH"'
    fi
    echo "⚠️ Pensez à recharger votre shell avec : source ~/.bashrc ou source ~/.zshrc"
  fi
fi

echo "🎉 Toutes les dépendances sont présentes. Vous pouvez continuer."

# Ici tu peux lancer la suite de ton script...
