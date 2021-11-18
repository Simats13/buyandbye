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


  const paymentMethod = await stripe.paymentMethods.detach(
      `${idCard}`,
  );

  res.json({
    paymentMethod: paymentMethod,
  });
});

app.post("/update_cards", async (req, res) => {
  const {SECRET_KEY} = getKeys();
  const stripe = new Stripe(SECRET_KEY as string, {
    apiVersion: "2020-08-27",
    typescript: true,
  });
  // const customers = await stripe.customers.list();
  // const customer = customers.data[0];

  const idCard = req.query.idCard;
  const customerCard = req.query.customerCard;
  const monthCard = req.query.monthCard;
  const yearCard = req.query.yearCard;
  const nameCard = req.query.nameCard;
  const streetCard = req.query.streetCard;
  const street2Card = req.query.street2Card;
  const cityCard = req.query.cityCard;
  const postalCodeCard = req.query.postalCodeCard;
  const stateCard = req.query.stateCard;
  const countryCard = req.query.countryCard;


  if (!idCard) {
    res.send({
      error: "You have no payment method created",
    });
  }
  const card = await stripe.customers.updateSource(
      `${customerCard}`,
      `${idCard}`,
      {
        name: `${nameCard}`,
        address_country: `${countryCard}`,
        address_zip: `${postalCodeCard}`,
        address_city: `${cityCard}`,
        address_line1: `${streetCard}`,
        address_line2: `${street2Card}`,
        exp_month: `${monthCard}`,
        exp_year: `${yearCard}`,
        address_state: `${stateCard}`,

      }
  );

  // const paymentMethod = await stripe.paymentMethods.update(
  //     `${idCard}`,
  //     {
  //       billing_details:
  //     {address:
  //       {
  //         city: `${cityCard}`,
  //         country: `${countryCard}`,
  //         line1: `${streetCard}`,
  //         line2: `${street2Card}`,
  //         postal_code: `${postalCodeCard}`,
  //         state: `${stateCard}`,
  //       },
  //     },
  //       card: {
  //         exp_month: monthCard,
  //         exp_year: yearCard,


  //       },
  //     },
  // );

  res.json({
    card: card,
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

  // const cards = await stripe.customers.listSources(
  //     `${customers}`,
  //     {object: "card", limit: 10}
  // );

  // const paymentMethods = await stripe.paymentMethods.list({
  //   customer: 'cus_KPCQxJNAdK4wIn',
  //   type: 'card',
  // });
  const paymentMethods = await stripe.paymentMethods.list({
    customer: `${customers}`,
    type: "card",
  });

  res.json({
    paymentMethods: paymentMethods,
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
