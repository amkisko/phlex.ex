#!/bin/bash

# End-to-end testing script for Phoenix Demo
# Tests all pages using curl

BASE_URL="http://localhost:4000"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

test_count=0
pass_count=0
fail_count=0

test_page() {
    local path=$1
    local name=$2
    test_count=$((test_count + 1))
    
    echo -n "Testing $name ($path)... "
    
    response=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL$path" 2>/dev/null)
    
    if [ "$response" = "200" ]; then
        echo -e "${GREEN}✓ PASS${NC} (HTTP $response)"
        pass_count=$((pass_count + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC} (HTTP $response)"
        fail_count=$((fail_count + 1))
        return 1
    fi
}

test_page_content() {
    local path=$1
    local name=$2
    local search_term=$3
    test_count=$((test_count + 1))
    
    echo -n "Testing $name content ($path)... "
    
    content=$(curl -s "$BASE_URL$path" 2>/dev/null)
    response_code=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL$path" 2>/dev/null)
    
    if [ "$response_code" = "200" ] && echo "$content" | grep -q "$search_term"; then
        echo -e "${GREEN}✓ PASS${NC} (found: $search_term)"
        pass_count=$((pass_count + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC} (HTTP $response_code, search: $search_term)"
        fail_count=$((fail_count + 1))
        return 1
    fi
}

echo "=========================================="
echo "Phoenix Demo End-to-End Test Suite"
echo "=========================================="
echo ""

# Check if server is running
echo -n "Checking if server is running... "
response_code=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL" 2>/dev/null || echo "000")
if [ "$response_code" = "200" ] || [ "$response_code" = "302" ] || [ "$response_code" = "404" ]; then
    echo -e "${GREEN}✓ Server is running${NC} (HTTP $response_code)"
else
    echo -e "${RED}✗ Server is not running${NC} (HTTP $response_code)"
    echo "Please start the server with: mix phx.server"
    exit 1
fi
echo ""

# Test main pages
echo "Testing Main Pages:"
echo "-------------------"
test_page "/" "Home/Index"
test_page "/auth" "Login"
test_page "/dashboard" "Dashboard"
test_page "/reservations" "Reservations"
test_page "/customers" "Customers"
test_page "/chat" "Chat"
test_page "/todos" "Todos"
test_page "/blog" "Blog"
test_page "/surveys" "Surveys"
test_page "/admin" "Admin"
echo ""

# Test admin pages
echo "Testing Admin Pages:"
echo "-------------------"
test_page "/admin/chat" "Admin Chat"
test_page "/admin/reservations" "Admin Reservations"
test_page "/admin/blog" "Admin Blog"
echo ""

# Test page content
echo "Testing Page Content:"
echo "-------------------"
test_page_content "/dashboard" "Dashboard" "Dashboard"
test_page_content "/reservations" "Reservations" "Reservations"
test_page_content "/customers" "Customers" "Customers"
test_page_content "/chat" "Chat" "Chat"
test_page_content "/todos" "Todos" "Task"
test_page_content "/blog" "Blog" "Blog"
test_page_content "/surveys" "Surveys" "Survey"
test_page_content "/admin" "Admin" "Admin"
echo ""

# Summary
echo "=========================================="
echo "Test Summary:"
echo "=========================================="
echo "Total tests: $test_count"
echo -e "${GREEN}Passed: $pass_count${NC}"
echo -e "${RED}Failed: $fail_count${NC}"
echo ""

if [ $fail_count -eq 0 ]; then
    echo -e "${GREEN}All tests passed! ✓${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed. ✗${NC}"
    exit 1
fi

