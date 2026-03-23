import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import Titlebar from "./components/Titlebar";
import LeadListPanel from "./components/LeadListPanel";
import LeadProfileView from "./components/LeadProfileView";
import CopilotPanel from "./components/CopilotPanel";
import BottomBar from "./components/BottomBar";

const queryClient = new QueryClient({
  defaultOptions: { queries: { staleTime: 1000 * 60 } },
});

export default function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <div style={{
        height: '100vh', display: 'flex', flexDirection: 'column',
        background: 'var(--color-bg-deep)',
      }}>
        <Titlebar />
        <div style={{ display: 'flex', flex: 1, overflow: 'hidden' }}>
          <LeadListPanel />
          <LeadProfileView />
          <CopilotPanel />
        </div>
        <BottomBar />
      </div>
    </QueryClientProvider>
  );
}
