/**
 * Implementation locale compatible avec workflow/api et @workflow/next pour l'orchestration autonome.
 */

type WorkflowFn<TInput, TResult> = (input: TInput) => Promise<TResult>;

export async function start<TInput, TResult>(
  workflow: WorkflowFn<TInput, TResult>,
  args: [TInput]
): Promise<{ id: string }> {
  setTimeout(() => {
    workflow(args[0]).catch((err: unknown) => {
      console.error("[WORKFLOW] Erreur d'execution:", err);
    });
  }, 0);
  return { id: "local-workflow-execution" };
}

export function serve<TInput, TResult>(workflow: WorkflowFn<TInput, TResult>) {
  return {
    POST: async (request: Request) => {
      const body = (await request.json()) as TInput;
      const result = await workflow(body);
      return new Response(JSON.stringify(result), {
        headers: { "Content-Type": "application/json" },
      });
    },
  };
}

export async function sleep(seconds: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, seconds * 1000));
}
