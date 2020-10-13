#!/bin/bash

# List member of Epsilo Infrastructure Team
list_user_name=("duyhla thanhnn")

# Get list public key of user
get_public_key_each_user()
{
    local user_key=$1
    if [[ "${user_key}" == "duyhla" ]];then
        user_pub_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCp73GQ7zUKL+loVjfAXilLN2vbUefDOpzKBB19mEvU3QoFHFYJIBkKW+FPgFu0lCH+1ajNwH2VkCNRNS/JDLEKfyjHaKiIXbNtzr6lqI4Oxiv2HCZ0ynJJkJWZo+eSocGcAzZDTELhJN5FWmwZhzaIPNmv2rAdP1RhXudE6Qu3l3tzqg5pDq6Akim42uZaAsPAlsS991rkBHU/8yVaIG8SuOt3A+EAfTNGiKxKBf/jyVN6OM+bQKpgpqaTUmbsZdGDnws4lrztzI/RjYmc7xf5PkF0s+fZjUKaIg0IvQVglqdRKRADjJhPKTv6FQvAUzJ97cY7pIotFwT8UVUkbcFN duy@duy-admin"

    elif [[ "${user_key}" == "thanhnn" ]];then
        user_pub_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC1LliDHldodFZmpMlbDZNJdGxzqHcZPVJ/ZrFYSIrH3Snh5iGJbaClXs1vJE0yNYI6T5miwwCAFCloYyKGpUZlfeuo9p4hZTvJ0DbBhqagBZmZAXviKKXeNjCMGpO7A5/0WOgxprK6/E8jin+KsQm9QEQyShDk+ff9y50KCbO2/AKDz+tlQsgz+ED+mVM2/gujxtKbWN3gOvEEN38k4oA1WsTpo1u5dfoyfbheIzyn5jItOrmHAQeGPHNYv3pLIMjB7vSp2JRH638mPXc6qdXd1tEccdmoZveMeMdPbv7VoG+LXJGvfE52KiWWYZ6SZLJWudyR8xPs8jeI66Rw6qvLtlq67JnUAYAKzWvg9N+BtiFjFA2WnBN+AFl+cbaBLUnob8+O5dX8XH8jXX3FSiVk/fUqa7aB0hcdRs217VK7jVvBAv9nM24KzaD4KBBtWLsJ2jZAzDCG/Jnd33fwvvfRmoXIpJLWR380N35q9Fpn9rKN2/lpeKTm6ufExP6aQGKG2LaymAz9g2ds9Hw4+CPhgtHR+EvE43FQ7WQ7EdB9Qc2Z05T2L5D/U6yu9Rp0/ndx/0uVwNu2mMmq9yXt6oFgi6XFpa/14PJJwgldE/MYY//6FgrrYWiZRUcYE56T6aokrp3hOGxduV4kbvVyyrv3L6SlA9QFPSWoKqHc0tTsgQ== thanh@thanh-ThinkPad-X260"

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
