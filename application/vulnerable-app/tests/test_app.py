import unittest

from app import app


class VulnerableAppSmokeTests(unittest.TestCase):
    def setUp(self):
        app.config["TESTING"] = True
        self.client = app.test_client()

    def test_health_endpoint(self):
        response = self.client.get("/health")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.get_json()["status"], "healthy")

    def test_homepage(self):
        response = self.client.get("/")
        self.assertEqual(response.status_code, 200)
        self.assertIn(b"Vulnerable Application", response.data)

    def test_metrics_endpoint(self):
        response = self.client.get("/metrics")
        self.assertEqual(response.status_code, 200)
        self.assertIn(b"app_up 1", response.data)

    def test_search_endpoint(self):
        response = self.client.get("/search", query_string={"username": "admin"})
        self.assertEqual(response.status_code, 200)
        self.assertIn(b"SQL Injection", response.data)


if __name__ == "__main__":
    unittest.main()
