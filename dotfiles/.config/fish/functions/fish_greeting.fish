function fish_greeting
    if test (uname) = "Darwin"
        command ssh-add -l >/dev/null
        if test $status = 1
            ssh-add ~/.ssh/.keys/*.key
        end
    end
end
