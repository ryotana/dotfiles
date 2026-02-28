function anyenv-init
    fish_add_path $HOME/.anyenv/bin
    anyenv init - fish | source

    if test -d $HOME/.anyenv/envs/rbenv
        set -gx RUBY_BASE_VERSION (rbenv version | awk '{print $1}' | awk -F'.' -v 'OFS=.' '{print $1,$2,0}')
        fish_add_path $HOME/.local/share/gem/ruby/$RUBY_BASE_VERSION/bin
    end

    if test -d $HOME/.anyenv/envs/nodenv
        set -gx NODE_BASE_VERSION (nodenv version | awk '{print $1}' | awk -F'.' -v 'OFS=.' '{print $1,$2,0}')
        fish_add_path $HOME/.anyenv/envs/nodenv/versions/$NODE_BASE_VERSION/bin
    end
end

function cd-anyenv --on-variable PWD
    if test -f "$PWD/Gemfile" -o -f "$PWD/package.json" -o -f "$PWD/go.mod"
        anyenv-init
    end
end
