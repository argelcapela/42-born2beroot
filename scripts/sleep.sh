sleep $(bc <<< $(who -b | cut -d ":" -f 2) % 10 * 60)
