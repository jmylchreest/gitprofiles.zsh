<p align="center">
  <a href="#gh-dark-mode-only" target="_blank" rel="noopener noreferrer">
    <img src=".github/assets/night.svg" alt="gitprofiles.plugin.zsh">
  </a>

  <a href="#gh-light-mode-only" target="_blank" rel="noopener noreferrer">
    <img src=".github/assets/day.svg" alt="gitprofiles.plugin.zsh">
  </a>
</p>

Plugin for managing multiple `git` profiles.

![](.github/assets/preview.gif)

## Installation

#### [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh)

```shell
git clone https://github.com/empresslabs/gitprofiles.plugin.zsh.git $ZSH_CUSTOM/plugins/gitprofiles
```

```shell
~/.zshrc
plugins=(... gitprofiles)
```

#### [zinit](https://github.com/zdharma-continuum/zinit)

```shell
zinit light empresslabs/gitprofiles.plugin.zsh
```

#### [zi](https://github.com/z-shell/zi)

```shell
zi light empresslabs/gitprofiles.plugin.zsh
```

#### [zgenom](https://github.com/jandamm/zgenom)

```shell
zgenom load empresslabs/gitprofiles.plugin.zsh
```

#### [zplug](https://github.com/zplug/zplug)

```shell
zplug empresslabs/gitprofiles.plugin.zsh
```

## Usage

#### Define where your profiles are stored

```sh
# ~/.zshrc

zstyle ":empresslabs:git:profile" path "$HOME/.config/git/profiles"
```

#### Add a new profile

```sh
# ~/.config/git/profiles

[profile "default"]
  name = Bruno Sales
  email = me@baliestri.dev
  # signingkey = 1234567890

[profile "work"]
  name = Bruno Sales
  email = work@baliestri.dev
  # signingkey = 1234567890
  path = "/home/baliestri/work"
```
