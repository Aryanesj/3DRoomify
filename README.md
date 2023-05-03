# Roomify Static Site Deployment

<p style="font-size: 1.5em; font-weight: bold;">🌐 <a href="https://3droomify.com" style="color: #34495e; text-decoration: underline;" target="_blank">3droomify.com</a></p>

**_This project contains Terraform code for deploying a static site on Google Cloud Platform (GCP) using Google Cloud Storage, Google Cloud Load Balancer, and Cloudflare for DNS management._**
***
## Overview

1. **GCP Storage Bucket**
   - <span style="color: rgb(0, 0, 255)">A storage bucket is created on GCP to host the static site's files.</span>
   - <span style="color:rgb(0, 0, 255)">The bucket is configured for public read access and as a website with a specified main page.</span>

2. **GitHub Repository**
   - <span style="color: rgb(26, 0, 230);">The GitHub repository containing the static site's code is defined as a data source.</span>

3. **Upload Files**
   - <span style="color: rgb(52, 0, 205);">The static site's files are cloned from the GitHub repository, built using npm, and uploaded to the GCP storage bucket using gsutil.</span>

4. **Global IP Address**
   - <span style="color: rgb(77, 0, 179);">A global IP address is reserved on GCP for the load balancer.</span>

5. **Backend Bucket**
   - <span style="color: rgb(103, 0, 154)">A backend bucket is created and configured to serve content from the GCP storage bucket.</span>

6. **URL Map**
   - <span style="color: rgb(128, 0, 128)">A URL map is created and configured to use the backend bucket as the default service.</span>

7. **HTTP Target Proxy**
   - <span style="color: rgb(154, 0, 103)">An HTTP target proxy is created and configured with the URL map.</span>

8. **Global Forwarding Rule**
   - <span style="color: rgb(179, 0, 77)">A global forwarding rule is created to route incoming traffic to the HTTP target proxy using the reserved global IP address.</span>

9. **Firewall Rule**
   - <span style="color: rgb(205, 0, 52)">A firewall rule is created to allow health checks on the default network.</span>

10. **Cloudflare A-record**
    - <span style="color: rgb(230, 0, 26)">An A-record is created in Cloudflare to point the domain name to the reserved global IP address.</span>

11. **Target HTTPS Proxy**
    - <span style="color: rgb(255, 0, 0)">An HTTPS target proxy is created and configured with the URL map and SSL certificate.</span>

12. **Update Global Forwarding Rule**
    - <span style="color: rgb(230, 26, 0)">The global forwarding rule is updated to route incoming traffic to the HTTPS target proxy using the reserved global IP address.</span>

13. **Managed SSL Certificate**
    - <span style="color: rgb(205, 52, 0)">A managed SSL certificate is requested in GCP for the domain name.</span>