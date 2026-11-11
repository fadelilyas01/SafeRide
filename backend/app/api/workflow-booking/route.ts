import { serve } from "@workflow/next";
import { bookingLifecycleWorkflow } from '@/workflows/booking-lifecycle';

// Expose le Vercel Workflow pour orchestration serverless résiliente de la réservation
export const { POST } = serve(bookingLifecycleWorkflow);
