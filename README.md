# Portfolio

## About

My portfolio site, [markchall.com](https://www.markchall.com), is a professional showcase built using the GatsbyJS framework and a starter template from [LekoArts](https://github.com/LekoArts/gatsby-starter-portfolio-cara). This project demonstrates my proficiency in leveraging modern web technologies and deploying scalable, serverless applications on the cloud.

## Architecture and Deployment

The portfolio site is designed as a serverless application, taking advantage of the scalability and cost-effectiveness offered by AWS services. The architecture includes:

- **AWS S3**: The static assets of the GatsbyJS application are hosted on Amazon S3, providing reliable and scalable storage.
- **Amazon CloudFront**: The site is distributed using Amazon CloudFront, a global content delivery network (CDN) that ensures fast and efficient content delivery to users worldwide.
- **Infrastructure as Code (IaC)**: The infrastructure for the portfolio site is provisioned and managed using Terraform, an industry-standard IaC tool. This approach ensures reproducibility, scalability, and easy maintainability of the infrastructure.
- **CI/CD Pipeline**: The deployment process is automated using GitHub Actions, a powerful CI/CD platform. Any changes to the codebase trigger a workflow that builds the GatsbyJS application, deploys the updated assets to AWS S3, and invalidates the CloudFront cache for seamless updates.

## DevOps and Site Reliability Engineering

As an aspiring DevOps or Site Reliability Engineer, I have designed and implemented this project to showcase my skills and expertise in the following areas:

- **Infrastructure as Code**: By using Terraform to define and manage the AWS infrastructure, I demonstrate my understanding of IaC principles and best practices, enabling efficient and reproducible infrastructure management.
- **Cloud Computing**: Leveraging AWS services such as S3 and CloudFront highlights my proficiency in architecting and deploying applications on the cloud, optimizing for scalability, performance, and cost-effectiveness.
- **CI/CD and Automation**: Implementing a CI/CD pipeline using GitHub Actions showcases my ability to automate the build, test, and deployment processes, ensuring rapid and reliable software delivery.
- **Monitoring and Logging**: I have integrated monitoring and logging solutions to gain visibility into the application's performance and identify potential issues proactively.

### Future Enhancements

I am continuously enhancing my portfolio site and expanding my skill set. One planned improvement includes:

- Migrating from GatsbyJS to Hugo as the static site generator. As the current GatsbyJS deployment is becoming deprecated and lacks optimal mobile performance, I plan to leverage Hugo's speed, simplicity, and mobile-friendly output to enhance the site's performance and user experience across devices.


Through this project, I aim to demonstrate my passion for DevOps and Site Reliability Engineering, showcasing my ability to design, deploy, and manage modern web applications on the cloud using industry-standard tools and best practices.
