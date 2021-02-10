## Rules
- **Codebreaker** is a logic game in which a code-breaker tries to break a **secret code** created by a code-maker. The **codemaker**, which will be played by the application we’re going to write, creates a secret code of **four numbers** between **1 and 6**.
- The codebreaker **gets** some number of chances to break the code (depends on chosen difficulty). In each turn, the codebreaker makes a guess of **4 numbers**. The **codemaker** then marks the guess with up to 4 signs **- +** or - or **empty spaces**.
- A + indicates an exact match: one of the numbers in the guess is the same as one of the numbers in the secret code and in the same position. For example:
  - **Secret number** - 1234.
  - **Input number** - 6264.
  - **Number of pluses** - 2 (second and fourth position).
- A - indicates a number match: one of the numbers in the guess is the same as one of the numbers in the secret code but in a different position. For example:
  - **Secret number** - 1234
  - **Input number** - 6462
  - **Number of minuses** - 2 (second and fourth position)
- An empty space indicates that there is not a current digit in a secret number.
- If **codebreaker** inputs the exact number as a secret number - **codebreaker** wins the game. If all attempts are spent - codebreaker loses.
- **Codebreaker** also has some number of hints(depends on chosen difficulty). If a user takes a hint - he receives back a separate digit of the secret code.
## Technologies
For development:
- **Ruby(v2.7.1)**
- **Rack**
- **I18n**

For testing:
- **Rubocop**
- **Fasterer**
- **Capybara**
- **Simplecov**

Also was used CircleCI for testing and deploying application to Heroku.
