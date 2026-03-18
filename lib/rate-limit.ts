import { NextResponse } from 'next/server';

const rateLimit = new Map<string, { count: number; resetTime: number }>();

export function rateLimiter(ip: string, limit: number = 10, windowMs: number = 60000) {
  const now = Date.now();
  const record = rateLimit.get(ip);

  if (!record || now > record.resetTime) {
    rateLimit.set(ip, { count: 1, resetTime: now + windowMs });
    return { success: true, remaining: limit - 1 };
  }

  if (record.count >= limit) {
    return { 
      success: false, 
      remaining: 0,
      resetTime: record.resetTime 
    };
  }

  record.count++;
  return { success: true, remaining: limit - record.count };
}

export function getRateLimitResponse(resetTime: number) {
  return NextResponse.json(
    { error: 'Too many requests. Please try again later.' },
    { 
      status: 429,
      headers: {
        'Retry-After': String(Math.ceil((resetTime - Date.now()) / 1000))
      }
    }
  );
}
