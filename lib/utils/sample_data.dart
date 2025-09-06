import 'package:uuid/uuid.dart';
import '../local_db/models/application_model.dart';
import '../local_db/models/user_model.dart';
import '../services/database_service.dart';

class SampleDataSeeder {
  static Future<void> seedSampleData() async {
    final db = DatabaseService.instance;

    // Check if data already exists
    final existingApps = db.getAllApplications();
    if (existingApps.isNotEmpty) {
      return; // Data already seeded
    }

    const uuid = Uuid();
    final now = DateTime.now();

    // Create sample applicants
    final applicants = [
      UserModel(
        id: uuid.v4(),
        name: 'Ahmed Ali',
        phone: '+92-300-1234567',
        age: 35,
        city: 'Karachi',
        role: UserRole.applicant,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 30)),
      ),
      UserModel(
        id: uuid.v4(),
        name: 'Fatima Khan',
        phone: '+92-301-2345678',
        age: 28,
        city: 'Lahore',
        role: UserRole.applicant,
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now.subtract(const Duration(days: 25)),
      ),
      UserModel(
        id: uuid.v4(),
        name: 'Muhammad Hassan',
        phone: '+92-302-3456789',
        age: 42,
        city: 'Islamabad',
        role: UserRole.applicant,
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 20)),
      ),
      UserModel(
        id: uuid.v4(),
        name: 'Aisha Malik',
        phone: '+92-303-4567890',
        age: 31,
        city: 'Faisalabad',
        role: UserRole.applicant,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 15)),
      ),
      UserModel(
        id: uuid.v4(),
        name: 'Omar Sheikh',
        phone: '+92-304-5678901',
        age: 26,
        city: 'Multan',
        role: UserRole.applicant,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
    ];

    // Save applicants
    for (final applicant in applicants) {
      await db.saveUser(applicant);
    }

    // Create sample applications
    final applications = [
      ApplicationModel(
        id: uuid.v4(),
        applicantId: applicants[0].id,
        applicantName: applicants[0].name,
        applicantPhone: applicants[0].phone,
        applicantAge: applicants[0].age,
        address: 'Gulshan-e-Iqbal, Karachi',
        category: HelpCategory.medical,
        description:
            'Urgent Heart Surgery Required\n\nI am a 35-year-old father of three children. Recently, I was diagnosed with a severe heart condition that requires immediate surgery. The doctor has informed us that without this operation, my condition will worsen rapidly.\n\nThe total cost of the surgery is PKR 800,000, which includes hospital charges, surgeon fees, and post-operative care. As a daily wage worker, I cannot afford this amount. My family has sold everything we could, but we are still short of the required funds.\n\nI humbly request your help to save my life so I can continue to support my family.',
        amountNeeded: 800000,
        documentPaths: [],
        status: ApplicationStatus.verified,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 10)),
        isUrgent: true,
      ),
      ApplicationModel(
        id: uuid.v4(),
        applicantId: applicants[1].id,
        applicantName: applicants[1].name,
        applicantPhone: applicants[1].phone,
        applicantAge: applicants[1].age,
        address: 'Johar Town, Lahore',
        category: HelpCategory.education,
        description:
            'University Fee Support for Final Year\n\nI am a final year Computer Science student at Punjab University. Due to my father\'s recent job loss during the pandemic, our family is facing severe financial difficulties.\n\nI need PKR 150,000 to pay my final year fees and complete my degree. I have maintained a 3.7 GPA and have been offered a good job upon graduation, but I cannot start without completing my degree.\n\nThis education will help me support my family and give back to the community in the future.',
        amountNeeded: 150000,
        documentPaths: [],
        status: ApplicationStatus.verified,
        createdAt: now.subtract(const Duration(days: 12)),
        updatedAt: now.subtract(const Duration(days: 8)),
        isUrgent: false,
      ),
      ApplicationModel(
        id: uuid.v4(),
        applicantId: applicants[2].id,
        applicantName: applicants[2].name,
        applicantPhone: applicants[2].phone,
        applicantAge: applicants[2].age,
        address: 'F-10, Islamabad',
        category: HelpCategory.housing,
        description:
            'Roof Repair After Heavy Rain Damage\n\nOur house roof was severely damaged during the recent heavy rains and flooding. Water is leaking into our home, making it unsafe for my elderly parents and young children.\n\nWe need PKR 200,000 to repair the roof, fix the water damage, and make our home livable again. As a government employee with a fixed salary, I cannot arrange this amount on short notice.\n\nWe are currently staying with relatives, but we urgently need to fix our home.',
        amountNeeded: 200000,
        documentPaths: [],
        status: ApplicationStatus.pending,
        createdAt: now.subtract(const Duration(days: 8)),
        updatedAt: now.subtract(const Duration(days: 8)),
        isUrgent: false,
      ),
      ApplicationModel(
        id: uuid.v4(),
        applicantId: applicants[3].id,
        applicantName: applicants[3].name,
        applicantPhone: applicants[3].phone,
        applicantAge: applicants[3].age,
        address: 'Madina Town, Faisalabad',
        category: HelpCategory.marriage,
        description:
            'Wedding Expenses for Daughter\n\nI am a widow raising my 22-year-old daughter alone. After years of struggle, we have found a good proposal for her marriage. The family is very understanding and supportive.\n\nI need PKR 300,000 to arrange a simple but dignified wedding ceremony. This includes basic furniture, wedding dress, and ceremony expenses. As a tailor, my income is limited, and I have been saving for years but still need help.\n\nYour support will help give my daughter a good start to her new life.',
        amountNeeded: 300000,
        documentPaths: [],
        status: ApplicationStatus.verified,
        createdAt: now.subtract(const Duration(days: 6)),
        updatedAt: now.subtract(const Duration(days: 3)),
        isUrgent: false,
      ),
      ApplicationModel(
        id: uuid.v4(),
        applicantId: applicants[4].id,
        applicantName: applicants[4].name,
        applicantPhone: applicants[4].phone,
        applicantAge: applicants[4].age,
        address: 'Shah Rukn-e-Alam Colony, Multan',
        category: HelpCategory.orphan,
        description:
            'Monthly Support for Orphaned Children\n\nI am taking care of my deceased brother\'s three children (ages 8, 10, and 12) along with my own family. My brother died in an accident last year, leaving these children orphaned.\n\nI need PKR 50,000 monthly to cover their school fees, food, clothing, and basic needs. As a shopkeeper with limited income, it\'s becoming difficult to manage expenses for seven people.\n\nThese children are excellent students and deserve a chance at a good education and future.',
        amountNeeded: 50000,
        documentPaths: [],
        status: ApplicationStatus.verified,
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 2)),
        isUrgent: false,
      ),
      ApplicationModel(
        id: uuid.v4(),
        applicantId: applicants[0].id,
        applicantName: applicants[0].name,
        applicantPhone: applicants[0].phone,
        applicantAge: applicants[0].age,
        address: 'Gulshan-e-Iqbal, Karachi',
        category: HelpCategory.medical,
        description:
            'Child Surgery for Cleft Lip\n\nMy 6-year-old son was born with a cleft lip condition. The doctor has recommended surgery to correct this condition, which will help him speak properly and boost his confidence.\n\nThe surgery costs PKR 250,000 including all medical expenses. This will be life-changing for my child and will help him integrate better with other children at school.\n\nWe have consulted multiple doctors and they all recommend this surgery at this age for best results.',
        amountNeeded: 250000,
        documentPaths: [],
        status: ApplicationStatus.fulfilled,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 5)),
        donorId: 'sample-donor-id',
        helpProvidedAt: now.subtract(const Duration(days: 5)),
        isUrgent: false,
      ),
    ];

    // Save applications
    for (final application in applications) {
      await db.saveApplication(application);
    }

    print('Sample data seeded successfully!');
  }
}
