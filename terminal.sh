#!/bin/bash


function necessary_packages {
    echo "Install the necessary packages."

    packages=(kitty zsh curl git fonts-firacode neovim tmux python3-pip python3-venv clangd ranger caca-utils highlight atool poppler-utils mediainfo ffmpegthumbnailer autojump libxext-dev apt-transport-https ca-certificates gnupg-agent software-properties-common silversearcher-ag tree)
    for package in "${packages[@]}"
    do
        sudo apt install -y "${package}"
    done

    echo "Install the necessary packages ... Done"
}


function oh_my_zsh {
    echo "Install Oh-my-zsh and dracula theme for zsh"

    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone https://github.com/dracula/zsh.git
    rm -rf ~/.oh_my_zsh/themes/*
    cp ./zsh/dracula.zsh-theme ~/.oh-my-zsh/themes
    cp -r ./zsh/lib ~/.oh-my-zsh/themes

    echo "Install Oh-my-zsh and dracula theme for zsh ... Done"

    echo "Install zsh-autosuggestions and zsh-syntax-highlighting for zsh"

    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

    echo "Install zsh-autosuggestions and zsh-syntax-highlighting for zsh ... Done"

    echo "Setting zsh"

    cp ./terminal/.zshrc ~/

    echo "Setting zsh ... Done"
}


function kitty {
    echo "Install dracula theme for kitty"

    git clone https://github.com/dracula/kitty.git
    mkdir -p ~/.config/kitty && touch ~/.config/kitty/kitty.conf
    cp ./kitty/dracula.conf ./kitty/diff.conf ~/.config/kitty
    echo "include dracula.conf" >> ~/.config/kitty/kitty.conf
    echo "font_family Fira Code Retina" >> ~/.config/kitty/kitty.conf

    echo "Install dracula theme for kitty ... Done"

    echo "Change default terminal to kitty"

    sudo update-alternatives --config x-terminal-emulator

    echo "Change default terminal to kitty ... Done"
}


function tmux {
    echo "Install tmux plugins manager"

    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    echo "Run Tmux and prefix + I to install package"

    echo "Install tmux plugins manager ... Done"

    echo "Setting tmux"

    cp ./terminal/.tmux.conf ~/

    echo "Setting tmux ... Done"
}


function ranger {
    echo "Install devicons, autojump, ueberzug, ffmpegthumbnailer for ranger"

    git clone https://github.com/alexanderjeurissen/ranger_devicons ~/.config/ranger/plugins/ranger_devicons
    sudo pip3 install ueberzug
    cp -r ./terminal/ranger/autojump ~/.config/ranger/plugins

    echo "Install devicons, autojump, ueberzug, ffmpegthumbnailer for ranger ... Done"

    echo "Setting ranger"

    cp ./terminal/ranger/rc.conf ./terminal/ranger/scope.sh ~/.config/ranger

    echo "Setting ranger ... Done"
}


function docker_and_docker_compose {
    echo "Install docker"

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo apt-key fingerprint 0EBFCD88
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker ${USER}
    su - ${USER}

    echo "Install docker ... Done"

    echo "Install docker_compose"

    sudo curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    echo "Install docker-compose ... Done"
}

function install_nvm_and_nodejs() {
    echo "Install nvm"
    
    export NVM_DIR="$HOME/.nvm" && (
        git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
        cd "$NVM_DIR"
        git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
    ) && \. "$NVM_DIR/nvm.sh"
    
    echo "Install nvm ... Done"
    
    echo "Install nodejs"
    
    nvm install node
    
    echo "Install nodejs ... Done"
}

function install_yarn() {
    echo "Install yarn"

    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt update && sudo apt install --no-install-recommends yarn
    
    echo "Install yarn ... Done"
}

function install_firacode() {
    echo "Install firacode"

    mkdir ~/.fonts
    cp ./"Fira Code Retina Nerd Font Complete.otf" ~/.fonts/

    echo "Install firacode ... Done"
}

necessary_packages
oh_my_zsh
kitty
tmux
ranger
docker_and_docker_compose
install_nvm_and_nodejs
install_yarn
install_firacode
