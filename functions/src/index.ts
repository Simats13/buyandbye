import * as functions from "firebase-functions";
import * as express from "express";
import Stripe from "stripe";
import * as env from "dotenv";
env.config({path: "./.env"});
const app = express();
const StripePublishableKey = process.env.STRIPE_PUBLISHABLE_KEY || "";
const StripeSecretKey = process.env.STRIPE_SECRET_KEY || "";

function getKeys(PAYMENT_METHOD?: string) {
  let SECRET_KEY: string | undefined = StripeSecretKey;
  let PUBLISHABLE_KEY: string | undefined = StripePublishableKey;

  switch (PAYMENT_METHOD) {
    case "grabpay":
    case "fpx":
      PUBLISHABLE_KEY = process.env.STRIPE_PUBLISHABLE_KEY_MY;
      SECRET_KEY = process.env.STRIPE_SECRET_KEY_MY;
      break;
    case "au_becs_debit":
      PUBLISHABLE_KEY = process.env.STRIPE_PUBLISHABLE_KEY_AU;
      SECRET_KEY = process.env.STRIPE_SECRET_KEY_AU;
      break;
    case "oxxo":
      PUBLISHABLE_KEY = process.env.STRIPE_PUBLISHABLE_KEY_MX;
      SECRET_KEY = process.env.STRIPE_SECRET_KEY_MX;
      break;
    default:
      PUBLISHABLE_KEY = process.env.STRIPE_PUBLISHABLE_KEY;
      SECRET_KEY = process.env.STRIPE_SECRET_KEY;
  }

  return {SECRET_KEY, PUBLISHABLE_KEY};
}

app.post("/delete_customer", async (req, res) => {
  const {SECRET_KEY} = getKeys();
  const stripe = new Stripe(SECRET_KEY as string, {
    apiVersion: "2020-08-27",
    typescript: true,
  });
  // const customers = await stripe.customers.list();
  // const customer = customers.data[0];
  const customers = req.query.customers;


  if (!customers) {
    res.send({
      error: "You have no customer created",
    });
  }

  const deleted = await stripe.customers.del(
      `${customers}`,
  );

  res.json({
    deleted: deleted,
    customer: `${customers}`,
  });
});


app.post("/delete_cards", async (req, res) => {
  const {SECRET_KEY} = getKeys();
  const stripe = new Stripe(SECRET_KEY as string, {
    apiVersion: "2020-08-27",
    typescript: true,
  });
  // const customers = await stripe.customers.list();
  // const customer = customers.data[0];
  const customers = req.query.customers;
  const idCard = req.query.idCard;


  if (!customers) {
    res.send({
      error: "You have no customer created",
    });
  }

  const deleted = await stripe.customers.deleteSource(
      `${customers}`,
      `${idCard}`,
  );

  res.json({
    deleted: deleted,
    customer: `${customers}`,
  });
});
app.post("/list_cards", async (req, res) => {
  const {SECRET_KEY} = getKeys();
  const stripe = new Stripe(SECRET_KEY as string, {
    apiVersion: "2020-08-27",
    typescript: true,
  });
  // const customers = await stripe.customers.list();
  // const customer = customers.data[0];
  const customers = req.query.customers;


  if (!customers) {
    res.send({
      error: "You have no customer created",
    });
  }

  const cards = await stripe.customers.listSources(
      `${customers}`,
      {object: "card", limit: 10}
  );
  // const paymentMethods = await stripe.paymentMethods.list({
  //   customer: `${customers}`,
  //   type: "card",
  // });

  res.json({

    cards: cards,
    customer: `${customers}`,
  });
});

app.post("/payment-sheet", async (req, res) => {
  const {SECRET_KEY} = getKeys();
  const stripe = new Stripe(SECRET_KEY as string, {
    apiVersion: "2020-08-27",
    typescript: true,
  });
  // const customers = await stripe.customers.list();
  // const customer = customers.data[0];
  const customers = req.query.customers;
  const amount = req.query.amount;

  if (!customers) {
    res.send({
      error: "You have no customer created",
    });
  }

  const ephemeralKey = await stripe.ephemeralKeys.create(
      {customer: `${customers}`},
      {apiVersion: "2020-08-27"}
  );
  const paymentIntent = await stripe.paymentIntents.create({
    amount: Number(amount),
    currency: "eur",
    customer: `${customers}`,
  });
  res.json({
    paymentIntent: paymentIntent.client_secret,
    ephemeralKey: ephemeralKey.secret,
    customer: `${customers}`,
  });
});
exports.app = functions.https.onRequest(app);
// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
