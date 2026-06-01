#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~ My Salon ~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id;")

  if [[ -z $AVAILABLE_SERVICES ]]
  then
    echo "Sorry, we don't have any services available right now."
  else

    echo -e "Welcome to My Salon, how can I help you?"

    echo "$AVAILABLE_SERVICES" | while IFS='|' read SERVICE_ID SERVICE_NAME
      do
        echo "$SERVICE_ID) $SERVICE_NAME"
      done

    read SERVICE_ID_SELECTED

    # if input is not a number
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else

      # check if service exists
      SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
      # if not exists
      if [[ -z $SERVICE_ID_SELECTED ]]
      then
        MAIN_MENU "I could not find that service. What would you like today?"
      else
  
        # get customer info
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE

        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
    
        # if customer doesn't exist
        if [[ -z $CUSTOMER_NAME ]]
        then
          echo -e "\nI don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME

          # insert new customer
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
        fi
  
        # get customer_id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")

        # get appointment details
        echo -e "\nWhat time would you like to book in for, $CUSTOMER_NAME?"
        read SERVICE_TIME

        # insert appointment details
        INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
        echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
      fi
    fi

  fi
}

MAIN_MENU
