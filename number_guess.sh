#!/bin/bash
PSQL="psql -U freecodecamp -d number_guess --tuples-only --no-align -c"

SECRET_NUMBER=$(( 0 + $RANDOM % 1000 ))

echo -e "\n~~~ Welcome to the number guessing game! ~~~\n"
echo "Enter your username:"
read USERNAME_ENTERED

USERNAME=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME_ENTERED'")
if [[ -z $USERNAME ]]
then
  NEW_USER=TRUE
  USERNAME=$USERNAME_ENTERED
  GAMES_PLAYED=0
  BEST_GAME=99999
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

GUESS() {
  if [[ $1 ]]
  then
    echo -e $1
  fi
  read NUMBER_GUESSED
  if [[ $NUMBER_GUESSED =~ ^[0-9]+$ ]]
  then
    NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))
    if [[ $NUMBER_GUESSED < $SECRET_NUMBER ]]
    then
      GUESS "\nIt's higher than that, guess again:"
    elif [[ $NUMBER_GUESSED > $SECRET_NUMBER ]]
    then 
      GUESS "\nIt's lower than that, guess again:"
    else
      echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    fi
  else
    GUESS "\nThat is not an integer, guess again:"
  fi
}

NUMBER_OF_GUESSES=0
GUESS "\nGuess the secret number between 1 and 1000:"

if [[ $NUMBER_OF_GUESSES < $BEST_GAME ]]
then
  BEST_GAME=$NUMBER_OF_GUESSES
fi
GAMES_PLAYED=$(( $GAMES_PLAYED + 1 ))

if [[ $NEW_USER = TRUE ]]
then
  INSERT_DATABASE_RESULT=$($PSQL "INSERT INTO users(username,games_played,best_game) VALUES('$USERNAME',$GAMES_PLAYED,$BEST_GAME)")
else
  UPDATE_DATABASE_RESULT=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED, best_game = $BEST_GAME WHERE username = '$USERNAME'")
fi
