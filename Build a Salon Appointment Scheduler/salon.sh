#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?"
SERVICES=$($PSQL "select service_id, name from services")

MAIN_MENU() {
  if [[ -n $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID" | sed 's/|/) /'
  done

  read SERVICE_ID_SELECTED

  SERVICE_ID_SELECTED_NAME=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_ID_SELECTED_NAME ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_PHONE_EXIST=$($PSQL "select phone from customers where phone = '$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_PHONE_EXIST ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      echo -e "\nWhat time would you like your cut, Fabio?"
      read SERVICE_TIME

      INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers(phone, name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
    CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE'")
    INSERT_APPOINTMENT_RESULT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    echo -e "I have put you down for a $SERVICE_ID_SELECTED_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU