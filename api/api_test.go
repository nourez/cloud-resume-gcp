package main

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestIncrementWithNewDatabase(t *testing.T) {
	var jsonStr = []byte(`{"pageUrl": "root"}`)
	req, err := http.NewRequest("GET", "/incrementCounter", bytes.NewBuffer(jsonStr))
	if err != nil {
		t.Fatal(err)
	}

	pageURL := "root"
	recorder := httptest.NewRecorder()
	handler := http.HandlerFunc(incrementCounterEndpoint)
	handler.ServeHTTP(recorder, req)

	if status := recorder.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v", status, http.StatusOK)
	}

	expected := HitCountResponse{
		Action: "Increment",
		Status: "Success",
		Page:   pageURL,
		Hits:   1,
	}
	expectedAsString, err := json.Marshal(expected)
	if err != nil {
		t.Errorf("Unable to parse JSON: %v", err)
	}

	var received HitCountResponse
	err = json.Unmarshal(recorder.Body.Bytes(), &received)
	if err != nil {
		t.Errorf("Unable to parse JSON: %v", err)
	}

	assert.Equal(t, expected, received, "handler returned unexpected body:\n got:\t %v want:\t %v", recorder.Body.String(), string(expectedAsString))

}

// func TestIncrementIncreasesHitCount(t *testing.T) {
// 	req, err := http.NewRequest("GET", "/incrementCounter", nil)
// 	if err != nil {
// 		t.Fatal(err)
// 	}

// 	recorder := httptest.NewRecorder()
// 	handler := http.HandlerFunc(incrementCounterEndpoint)
// 	handler.ServeHTTP(recorder, req)

// 	if status := recorder.Code; status != http.StatusOK {
// 		t.Errorf("handler returned wrong status code: got %v want %v", status, http.StatusOK)
// 	}

// 	// Test that a new record is created in the database
// 	expected := `{"action":"Increment","status":"Success","page":"rootPage","hits":2}`
// 	if recorder.Body.String() != expected {
// 		t.Errorf("handler returned unexpected body:\n got %v want %v", recorder.Body.String(), expected)
// 	}
// }
