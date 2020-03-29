#!/bin/bash

# List member of Epsilo Infrastructure Team
list_user_name=("duyhla" "kiettq")

# Get list public key of user
get_public_key_each_user()
{
    local user_key=$1
    if [[ "${user_key}" == "duyhla" ]];then
        user_pub_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCp73GQ7zUKL+loVjfAXilLN2vbUefDOpzKBB19mEvU3QoFHFYJIBkKW+FPgFu0lCH+1ajNwH2VkCNRNS/JDLEKfyjHaKiIXbNtzr6lqI4Oxiv2HCZ0ynJJkJWZo+eSocGcAzZDTELhJN5FWmwZhzaIPNmv2rAdP1RhXudE6Qu3l3tzqg5pDq6Akim42uZaAsPAlsS991rkBHU/8yVaIG8SuOt3A+EAfTNGiKxKBf/jyVN6OM+bQKpgpqaTUmbsZdGDnws4lrztzI/RjYmc7xf5PkF0s+fZjUKaIg0IvQVglqdRKRADjJhPKTv6FQvAUzJ97cY7pIotFwT8UVUkbcFN duy@duy-admin"

    elif [[ "${user_key}" == "kiettq" ]];then
        user_pub_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDMbYRnVhNrDpEuzgAYIytY4qtAl4kXMU9dFEQHoZSIVjKZeNmIDNwjRo2Y3MvWyz2XazR7hbesKdoOCM1jcfgnKB6R8LqTVqNRIdEL57WsduOnqTIo08mN7sJttM+6Kw63kB4/sN/vzzeEavbWHc6qaO1oVh2VjdnfTmzKg7+v7b6SxxfXqBwtqUJ9AJGGUo2lQMePMhQINN0W/spt/5SUk5Q/DZcRN//AkMUX8MipJ0DN8SUFcA/LkOo0bCJRqsc5YeZbVpUjehCQwlIoaOat6obOzfx2vcmpeVroe2waiecG/lNo6Pa1SwWGOcJjHURHcSNxdnkN324NBxkgRwQlMM9uDum2+IAfdUly6nQ7I9LIsTbxryFuJSQCMoRsxtIU/D6TmgrokLqDuLs18ojcR3yGW+EbzUiZu6B9I3czQqPfDPGbVRZJ+sdit4kdLipSI1aIw+6PbEUwODumbnj0Rp1dMQ2pHTopaj567L5i7DUZ2+hQ7NGZD2EoulKirU0= kiet@kiet"

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
