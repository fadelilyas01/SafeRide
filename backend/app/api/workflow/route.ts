import { serve } from "@workflow/next";
import { tripMonitorWorkflow } from '@/workflows/trip-monitor';

// Expose le Vercel Workflow pour orchestration serverless resiliente
export const { POST } = serve(tripMonitorWorkflow);
