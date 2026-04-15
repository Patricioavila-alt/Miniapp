"""
Backend API Tests for MiniApp Health Assistant
Tests: Home, Doctors, Appointments, Profile, Prescriptions, Documents, Signature Documents
"""
import pytest
import requests


class TestHomeEndpoint:
    """Test /api/home endpoint"""
    
    def test_home_returns_200(self, api_client, base_url):
        response = api_client.get(f"{base_url}/api/home")
        assert response.status_code == 200, f"Expected 200, got {response.status_code}"
        print("✓ GET /api/home returns 200")
    
    def test_home_has_required_fields(self, api_client, base_url):
        response = api_client.get(f"{base_url}/api/home")
        data = response.json()
        
        assert "user_name" in data, "Missing user_name field"
        assert "smart_widget" in data, "Missing smart_widget field"
        assert "quick_actions" in data, "Missing quick_actions field"
        assert "promotions" in data, "Missing promotions field"
        print(f"✓ Home data structure valid: user={data['user_name']}")
    
    def test_home_smart_widget_structure(self, api_client, base_url):
        response = api_client.get(f"{base_url}/api/home")
        data = response.json()
        widget = data["smart_widget"]
        
        assert "type" in widget, "Widget missing type"
        assert "data" in widget, "Widget missing data"
        assert widget["type"] in ["next_appointment", "welcome"], f"Invalid widget type: {widget['type']}"
        print(f"✓ Smart widget type: {widget['type']}")


class TestDoctorsEndpoint:
    """Test /api/doctors endpoints"""
    
    def test_get_all_doctors(self, api_client, base_url):
        response = api_client.get(f"{base_url}/api/doctors")
        assert response.status_code == 200
        doctors = response.json()
        assert isinstance(doctors, list), "Doctors should be a list"
        assert len(doctors) > 0, "Should have at least one doctor"
        print(f"✓ GET /api/doctors returns {len(doctors)} doctors")
    
    def test_doctor_has_required_fields(self, api_client, base_url):
        response = api_client.get(f"{base_url}/api/doctors")
        doctors = response.json()
        doc = doctors[0]
        
        required = ["id", "name", "specialty", "rating", "experience_years", "consultation_fee", "available_slots"]
        for field in required:
            assert field in doc, f"Doctor missing field: {field}"
        print(f"✓ Doctor structure valid: {doc['name']}")
    
    def test_search_doctors_by_name(self, api_client, base_url):
        response = api_client.get(f"{base_url}/api/doctors?search=Ana")
        assert response.status_code == 200
        doctors = response.json()
        assert len(doctors) > 0, "Search should return results"
        assert "Ana" in doctors[0]["name"], "Search result should match query"
        print(f"✓ Doctor search works: found {doctors[0]['name']}")
    
    def test_get_doctor_by_id(self, api_client, base_url):
        # First get all doctors
        response = api_client.get(f"{base_url}/api/doctors")
        doctors = response.json()
        doctor_id = doctors[0]["id"]
        
        # Get specific doctor
        response = api_client.get(f"{base_url}/api/doctors/{doctor_id}")
        assert response.status_code == 200
        doctor = response.json()
        assert doctor["id"] == doctor_id
        print(f"✓ GET /api/doctors/{doctor_id} works")
    
    def test_get_nonexistent_doctor(self, api_client, base_url):
        response = api_client.get(f"{base_url}/api/doctors/nonexistent-id")
        assert response.status_code == 404
        print("✓ GET /api/doctors/invalid returns 404")


class TestAppointmentsEndpoint:
    """Test /api/appointments endpoints"""
    
    def test_get_all_appointments(self, api_client, base_url):
        response = api_client.get(f"{base_url}/api/appointments")
        assert response.status_code == 200
        appointments = response.json()
        assert isinstance(appointments, list)
        print(f"✓ GET /api/appointments returns {len(appointments)} appointments")
    
    def test_get_upcoming_appointments(self, api_client, base_url):
        response = api_client.get(f"{base_url}/api/appointments?status=upcoming")
        assert response.status_code == 200
        appointments = response.json()
        for apt in appointments:
            assert apt["status"] == "upcoming", f"Expected upcoming, got {apt['status']}"
        print(f"✓ GET /api/appointments?status=upcoming returns {len(appointments)} appointments")
    
    def test_get_past_appointments(self, api_client, base_url):
        response = api_client.get(f"{base_url}/api/appointments?status=past")
        assert response.status_code == 200
        appointments = response.json()
        for apt in appointments:
            assert apt["status"] in ["completed", "cancelled"], f"Expected past status, got {apt['status']}"
        print(f"✓ GET /api/appointments?status=past returns {len(appointments)} appointments")
    
    def test_create_appointment_and_verify(self, api_client, base_url):
        # Get a doctor first
        doctors_response = api_client.get(f"{base_url}/api/doctors")
        doctors = doctors_response.json()
        doctor_id = doctors[0]["id"]
        
        # Create appointment
        payload = {
            "doctor_id": doctor_id,
            "date": "2026-05-01",
            "time": "10:00",
            "type": "video",
            "notes": "TEST_Automated test appointment"
        }
        create_response = api_client.post(f"{base_url}/api/appointments", json=payload)
        assert create_response.status_code == 200, f"Expected 200, got {create_response.status_code}"
        
        created_apt = create_response.json()
        assert "id" in created_apt, "Created appointment should have id"
        assert created_apt["doctor_id"] == doctor_id
        assert created_apt["date"] == payload["date"]
        assert created_apt["time"] == payload["time"]
        assert created_apt["status"] == "upcoming"
        print(f"✓ POST /api/appointments created appointment {created_apt['id']}")
        
        # Verify by GET
        apt_id = created_apt["id"]
        get_response = api_client.get(f"{base_url}/api/appointments/{apt_id}")
        assert get_response.status_code == 200
        fetched_apt = get_response.json()
        assert fetched_apt["id"] == apt_id
        assert fetched_apt["date"] == payload["date"]
        print(f"✓ GET /api/appointments/{apt_id} verified persistence")
        
        # Cleanup
        delete_response = api_client.delete(f"{base_url}/api/appointments/{apt_id}")
        assert delete_response.status_code == 200
        print(f"✓ DELETE /api/appointments/{apt_id} cleaned up test data")
    
    def test_get_appointment_by_id(self, api_client, base_url):
        response = api_client.get(f"{base_url}/api/appointments")
        appointments = response.json()
        if len(appointments) > 0:
            apt_id = appointments[0]["id"]
            response = api_client.get(f"{base_url}/api/appointments/{apt_id}")
            assert response.status_code == 200
            apt = response.json()
            assert apt["id"] == apt_id
            print(f"✓ GET /api/appointments/{apt_id} works")
    
    def test_cancel_appointment(self, api_client, base_url):
        # Create test appointment first
        doctors_response = api_client.get(f"{base_url}/api/doctors")
        doctor_id = doctors_response.json()[0]["id"]
        
        payload = {
            "doctor_id": doctor_id,
            "date": "2026-05-15",
            "time": "14:00",
            "type": "video"
        }
        create_response = api_client.post(f"{base_url}/api/appointments", json=payload)
        apt_id = create_response.json()["id"]
        
        # Cancel it
        delete_response = api_client.delete(f"{base_url}/api/appointments/{apt_id}")
        assert delete_response.status_code == 200
        data = delete_response.json()
        assert "message" in data
        print(f"✓ DELETE /api/appointments/{apt_id} cancelled appointment")


class TestProfileEndpoint:
    """Test /api/profile endpoints"""
    
    def test_get_profile(self, api_client, base_url):
        response = api_client.get(f"{base_url}/api/profile")
        assert response.status_code == 200
        profile = response.json()
        
        required = ["id", "full_name", "email", "phone", "date_of_birth", "gender", "blood_type", "allergies"]
        for field in required:
            assert field in profile, f"Profile missing field: {field}"
        print(f"✓ GET /api/profile returns profile for {profile['full_name']}")
    
    def test_update_profile_and_verify(self, api_client, base_url):
        # Get current profile
        get_response = api_client.get(f"{base_url}/api/profile")
        original_profile = get_response.json()
        
        # Update profile
        update_payload = {
            "full_name": "TEST_María García Updated",
            "phone": "+52 555 999 9999"
        }
        update_response = api_client.put(f"{base_url}/api/profile", json=update_payload)
        assert update_response.status_code == 200
        updated_profile = update_response.json()
        assert updated_profile["full_name"] == update_payload["full_name"]
        assert updated_profile["phone"] == update_payload["phone"]
        print(f"✓ PUT /api/profile updated profile")
        
        # Verify by GET
        verify_response = api_client.get(f"{base_url}/api/profile")
        verified_profile = verify_response.json()
        assert verified_profile["full_name"] == update_payload["full_name"]
        print(f"✓ GET /api/profile verified update persistence")
        
        # Restore original
        restore_payload = {
            "full_name": original_profile["full_name"],
            "phone": original_profile["phone"]
        }
        api_client.put(f"{base_url}/api/profile", json=restore_payload)
        print(f"✓ Profile restored to original state")


class TestPrescriptionsEndpoint:
    """Test /api/prescriptions endpoints"""
    
    def test_get_all_prescriptions(self, api_client, base_url):
        response = api_client.get(f"{base_url}/api/prescriptions")
        assert response.status_code == 200
        prescriptions = response.json()
        assert isinstance(prescriptions, list)
        assert len(prescriptions) > 0, "Should have at least one prescription"
        print(f"✓ GET /api/prescriptions returns {len(prescriptions)} prescriptions")
    
    def test_prescription_structure(self, api_client, base_url):
        response = api_client.get(f"{base_url}/api/prescriptions")
        prescriptions = response.json()
        rx = prescriptions[0]
        
        required = ["id", "doctor_name", "doctor_specialty", "date", "medications", "diagnosis", "qr_code_data", "status"]
        for field in required:
            assert field in rx, f"Prescription missing field: {field}"
        
        assert isinstance(rx["medications"], list), "Medications should be a list"
        assert len(rx["medications"]) > 0, "Should have at least one medication"
        print(f"✓ Prescription structure valid: {rx['diagnosis']}")
    
    def test_get_prescription_by_id(self, api_client, base_url):
        response = api_client.get(f"{base_url}/api/prescriptions")
        prescriptions = response.json()
        rx_id = prescriptions[0]["id"]
        
        response = api_client.get(f"{base_url}/api/prescriptions/{rx_id}")
        assert response.status_code == 200
        rx = response.json()
        assert rx["id"] == rx_id
        print(f"✓ GET /api/prescriptions/{rx_id} works")
    
    def test_get_nonexistent_prescription(self, api_client, base_url):
        response = api_client.get(f"{base_url}/api/prescriptions/nonexistent-id")
        assert response.status_code == 404
        print("✓ GET /api/prescriptions/invalid returns 404")


class TestDocumentsEndpoint:
    """Test /api/documents endpoints"""
    
    def test_get_all_documents(self, api_client, base_url):
        response = api_client.get(f"{base_url}/api/documents")
        assert response.status_code == 200
        documents = response.json()
        assert isinstance(documents, list)
        assert len(documents) > 0, "Should have at least one document"
        print(f"✓ GET /api/documents returns {len(documents)} documents")
    
    def test_document_structure(self, api_client, base_url):
        response = api_client.get(f"{base_url}/api/documents")
        documents = response.json()
        doc = documents[0]
        
        required = ["id", "title", "type", "date", "doctor_name", "summary", "status"]
        for field in required:
            assert field in doc, f"Document missing field: {field}"
        print(f"✓ Document structure valid: {doc['title']}")
    
    def test_get_document_by_id(self, api_client, base_url):
        response = api_client.get(f"{base_url}/api/documents")
        documents = response.json()
        doc_id = documents[0]["id"]
        
        response = api_client.get(f"{base_url}/api/documents/{doc_id}")
        assert response.status_code == 200
        doc = response.json()
        assert doc["id"] == doc_id
        print(f"✓ GET /api/documents/{doc_id} works")
    
    def test_get_nonexistent_document(self, api_client, base_url):
        response = api_client.get(f"{base_url}/api/documents/nonexistent-id")
        assert response.status_code == 404
        print("✓ GET /api/documents/invalid returns 404")


class TestSignatureDocumentsEndpoint:
    """Test /api/signature-documents endpoints"""
    
    def test_get_all_signature_documents(self, api_client, base_url):
        response = api_client.get(f"{base_url}/api/signature-documents")
        assert response.status_code == 200
        documents = response.json()
        assert isinstance(documents, list)
        assert len(documents) > 0, "Should have at least one signature document"
        print(f"✓ GET /api/signature-documents returns {len(documents)} documents")
    
    def test_signature_document_structure(self, api_client, base_url):
        response = api_client.get(f"{base_url}/api/signature-documents")
        documents = response.json()
        doc = documents[0]
        
        required = ["id", "title", "type", "date", "status", "content_preview"]
        for field in required:
            assert field in doc, f"Signature document missing field: {field}"
        print(f"✓ Signature document structure valid: {doc['title']}")
    
    def test_sign_document_and_verify(self, api_client, base_url):
        # Get a pending document
        response = api_client.get(f"{base_url}/api/signature-documents")
        documents = response.json()
        pending_docs = [d for d in documents if d["status"] == "pending"]
        
        if len(pending_docs) > 0:
            doc_id = pending_docs[0]["id"]
            
            # Sign it
            sign_response = api_client.post(f"{base_url}/api/signature-documents/{doc_id}/sign")
            assert sign_response.status_code == 200
            data = sign_response.json()
            assert "message" in data
            print(f"✓ POST /api/signature-documents/{doc_id}/sign works")
            
            # Verify status changed
            verify_response = api_client.get(f"{base_url}/api/signature-documents")
            updated_docs = verify_response.json()
            signed_doc = next((d for d in updated_docs if d["id"] == doc_id), None)
            assert signed_doc is not None
            assert signed_doc["status"] == "signed"
            print(f"✓ Document status verified as signed")
        else:
            print("⚠ No pending documents to test signing")


class TestPromotionsEndpoint:
    """Test /api/promotions endpoint"""
    
    def test_get_promotions(self, api_client, base_url):
        response = api_client.get(f"{base_url}/api/promotions")
        assert response.status_code == 200
        promotions = response.json()
        assert isinstance(promotions, list)
        assert len(promotions) > 0, "Should have at least one promotion"
        print(f"✓ GET /api/promotions returns {len(promotions)} promotions")
    
    def test_promotion_structure(self, api_client, base_url):
        response = api_client.get(f"{base_url}/api/promotions")
        promotions = response.json()
        promo = promotions[0]
        
        required = ["id", "title", "description", "image_url", "cta_text", "cta_action"]
        for field in required:
            assert field in promo, f"Promotion missing field: {field}"
        print(f"✓ Promotion structure valid: {promo['title']}")
