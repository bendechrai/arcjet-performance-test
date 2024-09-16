import { NextResponse } from 'next/server';
import arcjet, { detectBot } from '@arcjet/next';

const aj = arcjet({
  key: process.env.ARCJET_KEY!,
  rules: [
    detectBot({
      mode: "LIVE",
      allow: [], // Allow no known bots
    })
  ]
});

export async function GET(req: Request) {
  const decision = await aj.protect(req);

  if (decision.isDenied()) {
    return NextResponse.json({ error: "Bot Detected" }, { status: 403 });
  }

  return NextResponse.json({ message: 'Bot-protected endpoint' });
}
