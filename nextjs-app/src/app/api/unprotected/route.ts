import { NextResponse } from "next/server";

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

  // Perform CPU-intensive tasks
  const fibResult = calculateFibonacci(35);

  return NextResponse.json(
    { message: "Rate-limited endpoint", fibResult },
    { headers }
  );
}
