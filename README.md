# Party Drinks Calculator
After graduation, I wanted to throw a big party with my friends. The problem was that I had never done anything before so I didn't know how many drinks to buy. After searches on the internet and some empirical experimentation, I came out with this tool.  
It is a Shiny application helps you calculate the amount of drinks and ingredients needed for a party based on the number of guests, duration, and drink preferences. It also provides a breakdown of the types of drinks and the necessary amounts of ingredients and ice.

## Features

- **Input Parameters**: Number of guests, event duration, and percentages of different types of drinkers and drinks.
- **Calculation of Total Drinks**: Uses an exponential model to estimate the total number of drinks consumed.
- **Ingredient Calculation**: Provides the amount of ingredients needed for selected drinks.
- **Ice Calculation**: Estimates the amount of ice required for the drinks.
- **Graphical Representation**: Displays a bar chart showing the distribution of drinks.

## How to Use

1. **Input the Parameters**:
   - `Numero di invitati`: Number of guests.
   - `Durata dell'evento (ore)`: Duration of the event in hours.
   - `Percentuale Hard drinkers (%)`: Percentage of hard drinkers.
   - `Percentuale Medium drinkers (%)`: Percentage of medium drinkers.
   - `Percentuale Light drinkers (%)`: Percentage of light drinkers.
   - `Percentuale Astemi (%)`: Percentage of non-drinkers.
   - `Percentuale Birre (%)`: Percentage of beer.
   - `Percentuale Spritz (%)`: Percentage of Spritz.
   - `Percentuale Gin Tonic (%)`: Percentage of Gin Tonic.
   - `Percentuale Jägermeister (%)`: Percentage of Jägermeister.

2. **Calculate**:
   - Click the `Calcola` button to perform the calculations.

3. **View Results**:
   - `Risultati` tab: Shows the total number of each type of drink and their quantities in liters.
   - `Grafico` tab: Displays a bar chart of the drink distribution.
   - `Ingredienti` table: Lists the ingredients and their quantities needed.
   - `Ghiaccio` table: Displays the amount of ice required.
