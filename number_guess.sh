#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guessing_game -t --no-align -c"

echo Enter your username:

read USERNAME

PLAYER_DATA=$($PSQL "SELECT username, games_played, best_game FROM players WHERE username = '$USERNAME'")

# checking if player is in db

if [[ -z $PLAYER_DATA ]]
then

  INSERT_NEW_PLAYER_RESULT=$($PSQL "INSERT INTO players (username) VALUES ('$USERNAME')")

  echo "Welcome, $USERNAME! It looks like this is your first time here."

else

  echo $PLAYER_DATA | while IFS="|" read USERNAME GAMES_PLAYED BEST_GAME_GUESSES
  do

    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME_GUESSES guesses."

  done
fi

echo BEST GUESS: $BEST_GAME_GUESSES

#random num and num guesses init
RANDOM_NUMBER=$(( 1 + RANDOM % 1000 ))
NUMBER_OF_GUESSES=0

echo "Guess the secret number between 1 and 1000:"
read USER_GUESS

until [[ $USER_GUESS == $RANDOM_NUMBER ]]
do
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read USER_GUESS
    ((NUMBER_OF_GUESSES++))
  else

    if [[ $USER_GUESS > $RANDOM_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
      read USER_GUESS
      ((NUMBER_OF_GUESSES++))
    else
      echo "It's higher than that, guess again:"
      read USER_GUESS
      ((NUMBER_OF_GUESSES++))
    fi
  fi
done

((NUMBER_OF_GUESSES++))

#Final output message
echo You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!

# Update user data
UPDATE_GAMES_PLAYED_RESULT=$($PSQL "UPDATE players SET games_played = $GAMES_PLAYED + 1 WHERE username = '$USERNAME'")

if [[ $NUMBER_OF_GUESSES < $BEST_GAME_GUESSES || -z $BEST_GAME_GUESSES ]]
then
  UPDATE_BEST_GAME_RESULT=$($PSQL "UPDATE players SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME'")
fi

exit