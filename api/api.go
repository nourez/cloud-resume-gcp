package main

import (
	"context"
	"encoding/json"
	"log"
	"net/http"

	"cloud.google.com/go/firestore"
	"github.com/gorilla/mux"
)

const (
	defaultGoogleProjectID = "cloud-resume-sandbox"
)

type HitCountResponse struct {
	Action string `json:"action"`
	Status string `json:"status"`
	Page   string `json:"page"`
	Hits   int    `json:"hits"`
}

type HitCountRequest struct {
	PageURL string `json:"pageUrl"`
}

func createClient(ctx context.Context) *firestore.Client {
	client, err := firestore.NewClient(ctx, defaultGoogleProjectID)
	if err != nil {
		log.Fatalf("Failed to create client: %v", err)
	}
	return client
}

func pageExists(ctx context.Context, client *firestore.Client, pageURL string) bool {
	// Check if document with pageUrl exists
	_, err := client.Collection("hitCounts").Doc(pageURL).Get(ctx)
	return err == nil
}

func incrementCounterEndpoint(w http.ResponseWriter, r *http.Request) {
	const (
		internalServerError = http.StatusInternalServerError
		ok                  = http.StatusOK
	)

	// get body from request as a struct
	var body HitCountRequest
	var pageURL string

	err := json.NewDecoder(r.Body).Decode(&body)
	if err != nil {
		http.Error(w, "Failed to parse body", internalServerError)
		return
	}

	if body.PageURL == "" {
		http.Error(w, "PageURL is required", internalServerError)
		return
	}

	pageURL = body.PageURL

	// Open connection to Firestore
	ctx := context.Background()
	client := createClient(ctx)
	defer client.Close()

	pageDoc := client.Collection("hitCounts").Doc(pageURL)

	// Check if document with pageURL exists
	// If it does not exist, create it
	if !pageExists(ctx, client, pageURL) {
		_, err := pageDoc.Set(ctx, map[string]interface{}{
			"hitCount": 0,
			"pageUrl":  pageURL,
		})
		if err != nil {
			http.Error(w, "Failed to create document", internalServerError)
			return
		}
		log.Printf("Created document for pageURL: %s", pageURL)
	}

	// Get hitCount
	doc, err := pageDoc.Get(ctx)
	if err != nil {
		http.Error(w, "Failed to get hitCount", internalServerError)
		return
	}

	hitCount, err := doc.DataAt("hitCount")
	if err != nil {
		http.Error(w, "Failed to get hitCount", internalServerError)
		return
	}

	// Increment hitCount
	_, err = pageDoc.Update(ctx, []firestore.Update{
		{Path: "hitCount", Value: int(hitCount.(int64)) + 1},
	})
	if err != nil {
		http.Error(w, "Failed to increment hitCount", internalServerError)
		return
	}

	status := HitCountResponse{
		Action: "Increment",
		Status: "Success",
		Page:   pageURL,
		Hits:   int(hitCount.(int64)) + 1,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(status)
}

func main() {
	//http.HandleFunc("/incrementCounter", incrementCounterEndpoint)
	//http.ListenAndServe(":8080", nil)

	router := mux.NewRouter().StrictSlash(true)
	router.HandleFunc("/incrementCounter", incrementCounterEndpoint).Methods("POST")

	log.Fatal(http.ListenAndServe(":8080", router))
}
