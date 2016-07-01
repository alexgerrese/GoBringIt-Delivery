# BringIt

LARGE SCALE TODOS (in order of greatest to least priority):
- Do Restaurant List (DONE)
- Do Categories (DONE)
- Do Menu Items (DONE)
- Do Menu Sides (DONE)
- Figure out Global User ID accessible throughout the app (DONE)
- Do Ordering
- Do Checkout
- Do all restaurant hours & open/close switch
- Do Stripe
- Code Cleanup

SPECIFIC TODOS:
GENERAL
- Make sure all back buttons are custom (Alex)
- Optimize log in (it sometimes takes 10+ seconds, even if nothing is input at all) (Chad)
- Add new photos to the database (I also want to learn how so I can play around with them) (Chad and Alex)
- Fix all bottom button bugs (something just happened, some don’t work and one disappeared completely) (Alex)

ADD TO ORDER
- Add empty states in AddToOrder if there are no sides or extras (Alex)
- Make sure limits (e.g. pick 2) work with the radio buttons (right now you can select none or infinite) (Alex)
- Save item to DB cart with all the details when Add To Order is clicked (Chad)

CHECKOUT
- Fix the DeliverToPayWith bugs
    - Make sure only one cell can be checked at once (and one must be checked at all times) (Alex)
    - Pull address and payment info from DB (Chad)
    - Link to/create ways to add new addresses or payment methods (Alex)
- Pull db data to populate the tableview of items in cart (Chad)
- Calculate the total cost from db data  (Alex)
- Finalize checkout process (Chad)
- EXTRA: Find out if we can calculate ETA  (Alex)

SCHEDULE
- Pull past order data from db (Chad)
- Populate the tableview with the data (Alex)

SCHEDULE DETAILS
- Pull db data (Chad)
- Present the data (Alex)
- EXTRA: Add order again functionality  (Alex and Chad)

Questions:
- figure out where in DB Credit Card info should go
- only Sushi Love has restaurant hours in the DB; other restaurants do not
- figure out Password Recovery
