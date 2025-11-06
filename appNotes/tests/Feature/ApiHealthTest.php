<?php

namespace Tests\Feature;

use Tests\TestCase;

class ApiHealthTest extends TestCase
{
    public function test_api_health_endpoint_returns_success()
    {
        $response = $this->get('/api/health');

        $response->assertStatus(200)
                 ->assertJson([
                     'status' => 'OK',
                     'database' => 'connected'
                 ]);
    }

    public function test_api_routes_are_accessible()
    {
        // Test que les routes API principales existent
        $this->get('/api/health')->assertStatus(200);
    }
}