package main

import (
	"net/http/httptest"
	"testing"
)

func TestHealth(t *testing.T) {
	request := httptest.NewRequest("GET", "/healthz", nil)
	response := httptest.NewRecorder()
	handler().ServeHTTP(response, request)
	if response.Code != 200 || response.Body.String() != "ok\n" {
		t.Fatalf("unexpected health response: %d %q", response.Code, response.Body.String())
	}
}
