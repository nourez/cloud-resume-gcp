package main

import (
	"context"
	"log"
	"net/http"

	"cloud.google.com/go/firestore"
)

func createClient(ctx context.Context) *firestore.Client {
	client, err := firestore.NewClient(ctx, "cloud-resume-sandbox")
	if err != nil {
		log.Fatalf("Failed to create client: %v", err)
	}
	return client
}

func pageExists(pageUrl string) bool {
	ctx := context.Background()
	client := createClient(ctx)
	defer client.Close()

	// Check if document with pageUrl exists
	_, err := client.Collection("hitCounts").Doc(pageUrl).Get(ctx)
	if err != nil {
		return false
	}

	return true
}

func incrementCounterEndpoint(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	pageUrl := r.FormValue("pageUrl")
	if pageUrl == "" {
		pageUrl = "rootPage"
	}

	// Open connection to Firestore
	ctx := context.Background()
	firestoreConnection := createClient(ctx)
	defer firestoreConnection.Close()

	pageDoc := firestoreConnection.Collection("hitCounts").Doc(pageUrl)

	// Check if document with pageUrl exists
	// If it does not exist, create it
	if !pageExists(pageUrl) {
		_, err := pageDoc.Set(ctx, map[string]interface{}{
			"hitCount": 0,
			"pageUrl":  pageUrl,
		})
		if err != nil {
			http.Error(w, "Failed to create document", http.StatusInternalServerError)
			return
		}

		log.Printf("Created document for pageUrl: %s", pageUrl)
	}

	// Get hitCount
	doc, err := pageDoc.Get(ctx)
	if err != nil {
		http.Error(w, "Failed to get hitCount", http.StatusInternalServerError)
		return
	}

	hitCount, err := doc.DataAt("hitCount")
	if err != nil {
		http.Error(w, "Failed to get hitCount", http.StatusInternalServerError)
		return
	}

	// Increment hitCount
	_, err = pageDoc.Update(ctx, []firestore.Update{
		{Path: "hitCount", Value: hitCount.(int64) + 1},
	})
	if err != nil {
		http.Error(w, "Failed to increment hitCount", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Successfully incremented " + pageUrl))
}

func main() {
	http.HandleFunc("/incrementCounter", incrementCounterEndpoint)
	http.ListenAndServe(":8080", nil)
}
