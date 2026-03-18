export function logError(error: unknown, context?: string) {
  const timestamp = new Date().toISOString();
  const message = error instanceof Error ? error.message : String(error);
  const stack = error instanceof Error ? error.stack : '';
  
  console.error(`[${timestamp}] ${context || 'Error'}:`, message);
  if (stack) console.error(stack);
  
  // In production, send to monitoring service (Sentry, etc.)
  if (process.env.NODE_ENV === 'production') {
    // TODO: Integrate with error monitoring service
  }
}

export function logInfo(message: string, data?: any) {
  const timestamp = new Date().toISOString();
  console.log(`[${timestamp}] ${message}`, data || '');
}
