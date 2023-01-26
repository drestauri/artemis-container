myvar=$(cat /etc/*release | grep -i version | grep "8\.")

echo $myvar

if [ -z "$myvar" ]; then echo "yes"; else echo "no"; fi;

