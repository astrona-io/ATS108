package boards

import (
	"encoding/json"
	"strings"
	"testing"

	"github.com/perses/perses/go-sdk/dashboard"
)

func TestJobGroupsUsesEachJob(t *testing.T) {
	options := append([]dashboard.Option{dashboard.ProjectName("inventory")}, JobGroups([]string{"alpha", "beta"})...)
	builder, err := dashboard.New("test", options...)
	if err != nil {
		t.Fatal(err)
	}
	if got := len(builder.Dashboard.Spec.Layouts); got != 2 {
		t.Fatalf("expected 2 panel groups, got %d", got)
	}
	second, err := json.Marshal(builder.Dashboard.Spec.Panels["1_0"])
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(string(second), `job=\"beta\"`) {
		t.Fatalf("the second group must query job beta, got %s", second)
	}
}
