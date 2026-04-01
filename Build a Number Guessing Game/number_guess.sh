#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER=$((RANDOM % 1000 + 1))
echo $NUMBER

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "select user_id from users where username = '$USERNAME'")
if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "insert into users(username) values('$USERNAME')")
else
  GAME_PLAYED=$($PSQL "select count(*) from games where user_id=$USER_ID")
  BEST_GAME=$($PSQL "select min(number_of_guesses) from games where user_id=$USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAME_PLAYED games, and your best game took $BEST_GAME guesses."
fi

USER_ID=$($PSQL "select user_id from users where username = '$USERNAME'")

echo "Guess the secret number between 1 and 1000:"
read GUESS_NUMBER
NUMBER_OF_GUESS=1

while [[ $GUESS_NUMBER -ne $NUMBER ]]
do
  if [[ ! $GUESS_NUMBER =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    if [[ $GUESS_NUMBER -gt $NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
    NUMBER_OF_GUESS=$((NUMBER_OF_GUESS + 1))
  fi
  read GUESS_NUMBER
done

echo "You guessed it in $NUMBER_OF_GUESS tries. The secret number was $NUMBER. Nice job!"

INSERT_GAME_RESULT=$($PSQL "insert into games(user_id, number_of_guesses) values($USER_ID, $NUMBER_OF_GUESS)")