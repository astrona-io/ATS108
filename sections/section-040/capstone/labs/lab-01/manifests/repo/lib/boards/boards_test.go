package boards

import (
	"testing"

	"github.com/perses/perses/go-sdk/dashboard"
	panelgroup "github.com/perses/perses/go-sdk/panel-group"
)

func TestTargetsUpBuildsOnePanel(t *testing.T) {
	builder, err := dashboard.New("test",
		dashboard.ProjectName("inventory"),
		dashboard.AddPanelGroup("Scrape health", panelgroup.PanelsPerLine(1), TargetsUp("prometheus")),
	)
	if err != nil {
		t.Fatal(err)
	}
	if got := len(builder.Dashboard.Spec.Panels); got != 1 {
		t.Fatalf("expected 1 panel, got %d", got)
	}
}
