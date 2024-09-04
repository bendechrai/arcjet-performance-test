import { NextResponse } from 'next/server';
import arcjet, { fixedWindow } from '@arcjet/next';

const aj = arcjet({
  key: process.env.ARCJET_KEY!,
  rules: [
    fixedWindow({
      mode: "LIVE", // will block requests. Use "DRY_RUN" to log only
      window: 60, // 60 second fixed window
      max: 10, // allow a maximum of 10 requests
    })
  ]
});

export async function GET(req: Request) {
  const decision = await aj.protect(req);

  if (decision.isDenied()) {
    return NextResponse.json({ error: "Too Many Requests" }, { status: 429 });
  }

  return NextResponse.json({ message: 'Rate-limited endpoint' });
}
