#!/usr/bin/env bash
# Test script untuk domain regex validation

test_domain_regex() {
    local domain="$1"
    # Regex untuk multi-level subdomain dengan validasi lengkap
    # - Tidak boleh diawali atau diakhiri dengan dash di setiap label
    # - Minimal 2 label: example.com, vpn.example.com, n.ahemmm.my.id
    local domain_regex='^[a-zA-Z0-9]([a-zA-Z0-9\-]*[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]*[a-zA-Z0-9])?)+$'

    if [[ $domain =~ $domain_regex ]]; then
        echo "✓ VALID:   $domain"
        return 0
    else
        echo "✗ INVALID: $domain"
        return 1
    fi
}

echo "Testing Domain Regex Validation"
echo "================================"
echo

# Test valid domains
echo "Valid Domains:"
echo "-------------"
test_domain_regex "example.com"
test_domain_regex "vpn.example.com"
test_domain_regex "n.ahemmm.my.id"
test_domain_regex "api.v2.prod.example.com"
test_domain_regex "sub.domain.co.uk"
test_domain_regex "test-server.example.org"
echo

# Test invalid domains
echo "Invalid Domains:"
echo "---------------"
test_domain_regex "-invalid.com"
test_domain_regex "invalid-.com"
test_domain_regex "example"
test_domain_regex ".example.com"
test_domain_regex "example..com"
test_domain_regex ""
test_domain_regex "sub.-domain.com"
test_domain_regex "sub.domain-.com"
echo

echo "Testing complete!"
