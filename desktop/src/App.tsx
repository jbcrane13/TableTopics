import { useState } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

const queryClient = new QueryClient({
  defaultOptions: { queries: { staleTime: 1000 * 60 } },
});

// Panels — stubs to fill in during Week 1-4
function LeadListPanel({ onSelect }: { onSelect: (id: string) => void }) {
  return (
    <aside className="w-72 border-r border-gray-200 flex flex-col bg-white">
      <div className="p-4 border-b border-gray-100">
        <input
          placeholder="Search leads…"
          className="w-full px-3 py-2 text-sm border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
      </div>
      <div className="flex-1 overflow-y-auto p-2">
        <p className="text-xs text-gray-400 text-center mt-8">
          No leads yet — connect to B2BPlatform
        </p>
      </div>
    </aside>
  );
}

function CenterPanel({ leadId }: { leadId: string | null }) {
  return (
    <main className="flex-1 flex flex-col bg-gray-50">
      {leadId ? (
        <div className="p-6">
          <p className="text-gray-400">Lead profile coming in Week 2</p>
        </div>
      ) : (
        <div className="flex-1 flex items-center justify-center text-gray-400 text-sm">
          Select a lead to get started
        </div>
      )}
    </main>
  );
}

function CopilotPanel({ leadId }: { leadId: string | null }) {
  return (
    <aside className="w-80 border-l border-gray-200 flex flex-col bg-white">
      <div className="p-4 border-b border-gray-100">
        <h2 className="text-sm font-semibold text-gray-700">AI Copilot</h2>
      </div>
      <div className="flex-1 flex items-center justify-center p-4">
        <p className="text-xs text-gray-400 text-center">
          {leadId
            ? "Select a mode to get started"
            : "Select a lead to use the copilot"}
        </p>
      </div>
    </aside>
  );
}

export default function App() {
  const [selectedLeadId, setSelectedLeadId] = useState<string | null>(null);

  return (
    <QueryClientProvider client={queryClient}>
      <div className="h-screen flex flex-col bg-white">
        {/* Header */}
        <header className="h-12 border-b border-gray-200 flex items-center px-4 gap-3 shrink-0">
          <span className="font-semibold text-gray-900 text-sm">LeadForge</span>
          <span className="text-gray-300 text-xs">|</span>
          <span className="text-xs text-gray-500">TableTopics</span>
        </header>

        {/* Three-column body */}
        <div className="flex flex-1 overflow-hidden">
          <LeadListPanel onSelect={setSelectedLeadId} />
          <CenterPanel leadId={selectedLeadId} />
          <CopilotPanel leadId={selectedLeadId} />
        </div>
      </div>
    </QueryClientProvider>
  );
}
