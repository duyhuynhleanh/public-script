#!/bin/bash

# List member of Epsilo Infrastructure Team
list_user_name=("duyhla")

# Get list public key of user
get_public_key_each_user()
{
    local user_key=$1
    if [[ "${user_key}" == "duyhla" ]];then
        user_pub_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCp73GQ7zUKL+loVjfAXilLN2vbUefDOpzKBB19mEvU3QoFHFYJIBkKW+FPgFu0lCH+1ajNwH2VkCNRNS/JDLEKfyjHaKiIXbNtzr6lqI4Oxiv2HCZ0ynJJkJWZo+eSocGcAzZDTELhJN5FWmwZhzaIPNmv2rAdP1RhXudE6Qu3l3tzqg5pDq6Akim42uZaAsPAlsS991rkBHU/8yVaIG8SuOt3A+EAfTNGiKxKBf/jyVN6OM+bQKpgpqaTUmbsZdGDnws4lrztzI/RjYmc7xf5PkF0s+fZjUKaIg0IvQVglqdRKRADjJhPKTv6FQvAUzJ97cY7pIotFwT8UVUkbcFN duy@duy-admin"

    elif [[ "${user_key}" == "some-user-here" ]];then
        user_pub_key="ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAv1qVqdNBDse8M+75zT8b8SkQp0NtXZVh1j/STfo4Y/RrVi32AHCjc4wXvLxN3+sn9JmJqsDwKsEKiYSy3L7T1Kl9wLzuI7ubQ4Y18c6ANnEr26rgLUqY6Nvq6k0CqzTvVr2vEh7NJCB+QGJY9LyYnr/uQSZTUUUHHI/T2/mNe8Hbko/TcmtHKaJxUsR95fdGCCXbt+6mCtYXZd5CwhLQIIQ8XlZ6Y1u1O8ZZAYIvvKU/lWrCpl2d/xLdQxaMO2jruwmipSFWR5Yb17OJiUAquVaZ1V9K0retkgFuzoKV7lGK8M0bQsq2YsrJftwe9JHrAUo4w4MyaMkBG97NSahnUQ== nguyennt"

    fi
    echo "${user_pub_key}"
}

# Add user
for user in "${list_user_name[@]}"
do
    useradd -m "${user}"
    mkdir -p /home/${user}/.ssh/
    touch /home/${user}/.ssh/authorized_keys
    chmod 600 /home/${user}/.ssh/authorized_keys
    chmod 700 /home/${user}/.ssh/
    user_public_key="$(get_public_key_each_user ${user})"
    echo "${user_public_key}" > /home/${user}/.ssh/authorized_keys
    chown ${user}:${user} -R /home/${user}/

    if [[ ! "$(grep ${user} /etc/sudoers)" ]];then
        echo "${user} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
        if [[ "${user}" == "ansible" ]];then
            echo 'Defaults:ansible !requiretty' >> /etc/sudoers
        fi
    fi

    # Checking
    if [[ "$(grep ${user} /etc/passwd)" ]];then
        echo "-+ Creating user [${user}] is successful ."
    else 
        echo "-+ Creating user [${user}] is FAILED ."
    fi

    if [[ "$(cat /home/${user}/.ssh/authorized_keys | wc -c)" -gt 250 ]];then
        echo "-+ Updated public key for user [${user}] is successful."
    else 
        echo "-+ Updated public key for user [${user}] is FAILED."
    fi

    if [[ "$(grep "^${user}" /etc/sudoers)" ]];then
        echo "-+ Updated Sudo permission for user [${user}] is successful."
    else 
        echo "-+ Updated Sudo permission for user [${user}] is FAILED."
    fi
    echo " "
done

echo "-+ Finish script add user Epsilo Infrastructure Team."

exit 0
