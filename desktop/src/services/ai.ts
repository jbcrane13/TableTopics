import { api } from "./api";

export interface CopilotRequest {
  mode: "draft_proposal" | "rewrite" | "customer_response" | "document";
  leadId: string;
  context?: string; // current draft content
  instruction?: string;
}

export interface CopilotResponse {
  content: string;
  tokensUsed: number;
}

export const aiService = {
  generate: (req: CopilotRequest) =>
    api.post<CopilotResponse>("/ai/copilot", req),
};
