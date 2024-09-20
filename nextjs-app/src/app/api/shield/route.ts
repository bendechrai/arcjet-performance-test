import { NextResponse } from "next/server";
import arcjet, { shield } from "@arcjet/next";

const aj = arcjet({
  key: process.env.ARCJET_KEY!,
  rules: [
    shield({
      mode: "LIVE",
    }),
  ],
});

// Function to calculate Fibonacci sequence iteratively (create some load to this page render)
function calculateFibonacci(n: number): number {
  let a = 0,
    b = 1,
    temp;
  while (n > 0) {
    temp = a;
    a = b;
    b = temp + b;
    n--;
  }
  return a;
}

export async function GET(req: Request) {
  const headers = {
    "Cache-Control":
      "no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0",
    Pragma: "no-cache",
    Expires: "0",
  };

  const decision = await aj.protect(req);
  if (decision.isDenied()) {
    return NextResponse.json(
      { error: "Bot Detected" },
      { ...headers, status: 403 }
    );
  }

  // Perform CPU-intensive tasks
  const fibResult = calculateFibonacci(35);

  return NextResponse.json(
    { message: "Bot-protected endpoint", fibResult },
    { headers }
  );
}
