#!/usr/bin/env python3
"""Build a logical, feature-ordered git history for inD."""
import subprocess
import sys
from pathlib import Path

ROOT = Path(r"c:\Users\USER\Desktop\fl")

COMMITS = [
    ("docs: add project README and root gitignore", [".gitignore", "README.md"]),
    (
        "chore(backend): initialize Spring Boot project scaffold",
        [
            "SrrFrr-App-Back-preprod/pom.xml",
            "SrrFrr-App-Back-preprod/mvnw",
            "SrrFrr-App-Back-preprod/mvnw.cmd",
            "SrrFrr-App-Back-preprod/.mvn",
            "SrrFrr-App-Back-preprod/.gitattributes",
            "SrrFrr-App-Back-preprod/.gitignore",
            "SrrFrr-App-Back-preprod/liquibase.properties",
        ],
    ),
    (
        "chore(backend): add local docker compose stack",
        [
            "SrrFrr-App-Back-preprod/docker-compose.yml",
            "SrrFrr-App-Back-preprod/docker-entrypoint-initdb.d",
        ],
    ),
    (
        "chore(backend): configure application profiles and env",
        [
            "SrrFrr-App-Back-preprod/src/main/resources/application.properties",
            "SrrFrr-App-Back-preprod/src/main/resources/application-dev.yml",
            "SrrFrr-App-Back-preprod/src/main/resources/application-preprod.yml",
            "SrrFrr-App-Back-preprod/src/main/resources/application-prod.yml",
            "SrrFrr-App-Back-preprod/src/main/resources/config",
            "SrrFrr-App-Back-preprod/src/main/resources/META-INF",
        ],
    ),
    (
        "feat(backend): add liquibase schema and core tables",
        [
            "SrrFrr-App-Back-preprod/src/main/resources/db/changelog/db.changelog-master.yaml",
            "SrrFrr-App-Back-preprod/src/main/resources/db/changelog/app/tables/002-create-passenger-table.yaml",
            "SrrFrr-App-Back-preprod/src/main/resources/db/changelog/app/tables/003-create-driver-table.yaml",
            "SrrFrr-App-Back-preprod/src/main/resources/db/changelog/app/tables/004-create-authentication-table.yaml",
            "SrrFrr-App-Back-preprod/src/main/resources/db/changelog/app/tables/005-create-wallet-table.yaml",
            "SrrFrr-App-Back-preprod/src/main/resources/db/changelog/app/tables/006-create-wallet-transaction-table.yaml",
            "SrrFrr-App-Back-preprod/src/main/resources/db/changelog/app/tables/007-create-ride-table.yaml",
        ],
    ),
    (
        "feat(backend): extend database with subscriptions and chat",
        [
            "SrrFrr-App-Back-preprod/src/main/resources/db/changelog/app/tables/008-create-subscription-plan-table.yaml",
            "SrrFrr-App-Back-preprod/src/main/resources/db/changelog/app/tables/009-create-driver-subscription-table.yaml",
            "SrrFrr-App-Back-preprod/src/main/resources/db/changelog/app/tables/011-create-loyalty-reward-table.yaml",
            "SrrFrr-App-Back-preprod/src/main/resources/db/changelog/app/tables/012-create-loyalty-transaction-table.yaml",
            "SrrFrr-App-Back-preprod/src/main/resources/db/changelog/app/tables/013-create-chat-channel-table.yaml",
            "SrrFrr-App-Back-preprod/src/main/resources/db/changelog/app/tables/014-create-chat-message-table.yaml",
            "SrrFrr-App-Back-preprod/src/main/resources/db/changelog/app/tables/015-create-message-file-table.yaml",
        ],
    ),
    (
        "feat(backend): add ratings, notifications and support tables",
        [
            "SrrFrr-App-Back-preprod/src/main/resources/db/changelog/app/tables/016-create-rating-values-table.yaml",
            "SrrFrr-App-Back-preprod/src/main/resources/db/changelog/app/tables/017-create-rating-table.yaml",
            "SrrFrr-App-Back-preprod/src/main/resources/db/changelog/app/tables/018-create-notification-table.yaml",
            "SrrFrr-App-Back-preprod/src/main/resources/db/changelog/app/tables/019-create-reclamation-table.yaml",
            "SrrFrr-App-Back-preprod/src/main/resources/db/changelog/app/tables/020-create-invite-table.yaml",
            "SrrFrr-App-Back-preprod/src/main/resources/db/changelog/app/tables/021-create-otp-table.yaml",
            "SrrFrr-App-Back-preprod/src/main/resources/db/changelog/app/tables/022-create-subscription-plan-description.yaml",
            "SrrFrr-App-Back-preprod/src/main/resources/db/changelog/app/tables/023-create-driver-profile-edit-request-table.yaml",
            "SrrFrr-App-Back-preprod/src/main/resources/db/changelog/app/fk",
            "SrrFrr-App-Back-preprod/src/main/resources/db/changelog/app/data",
        ],
    ),
    (
        "feat(backend): add archive schema migrations",
        ["SrrFrr-App-Back-preprod/src/main/resources/db/changelog/archive"],
    ),
    (
        "feat(backend): add core entities and enums",
        [
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/entities",
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/enums",
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/annotations",
        ],
    ),
    (
        "feat(backend): add DTOs and shared API responses",
        ["SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/dto"],
    ),
    (
        "feat(backend): add repositories layer",
        ["SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/repositories"],
    ),
    (
        "feat(backend): add exception handling framework",
        ["SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/exceptions"],
    ),
    (
        "feat(backend): configure security, JWT and AWS integrations",
        [
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/configurations",
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/infrastructure",
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/constants",
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/utils",
        ],
    ),
    (
        "feat(backend): implement authentication and OTP services",
        [
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/services/auth",
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/controllers/AuthController.java",
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/controllers/OtpController.java",
        ],
    ),
    (
        "feat(backend): implement user profile and driver onboarding",
        [
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/services/user",
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/controllers/UserController.java",
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/controllers/DriverProfileEditRequestController.java",
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/controllers/internal",
        ],
    ),
    (
        "feat(backend): add ride domain logic and pricing",
        [
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/domain",
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/services/ride",
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/services/location",
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/controllers/RideController.java",
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/controllers/GoogleMapsController.java",
        ],
    ),
    (
        "feat(backend): add realtime ride matching over WebSocket",
        ["SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/websocket"],
    ),
    (
        "feat(backend): implement wallet, payments and subscriptions",
        [
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/services/payment",
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/services/subscription",
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/controllers/WalletController.java",
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/controllers/SubscriptionController.java",
        ],
    ),
    (
        "feat(backend): add chat, notifications and loyalty modules",
        [
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/services/chat",
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/services/notification",
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/services/loyalty",
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/services/reclamation",
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/services/rating",
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/services/invite",
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/controllers/ChatController.java",
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/controllers/NotificationController.java",
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/controllers/LoyaltyController.java",
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/controllers/RatingController.java",
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/controllers/ReclamationController.java",
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/controllers/InviteController.java",
        ],
    ),
    (
        "feat(backend): add internal admin services and migrations",
        [
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/services/internal",
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/migrations",
            "SrrFrr-App-Back-preprod/src/main/java/com/srrfrr/api/SrrFrrBackEndApplication.java",
        ],
    ),
    (
        "ci(backend): add GitHub Actions pipeline and code quality rules",
        [
            "SrrFrr-App-Back-preprod/.github",
            "SrrFrr-App-Back-preprod/config",
            "SrrFrr-App-Back-preprod/src/test",
        ],
    ),
    (
        "chore(frontend): initialize Flutter project",
        [
            "SrrFrr-App-Front-main/pubspec.yaml",
            "SrrFrr-App-Front-main/analysis_options.yaml",
            "SrrFrr-App-Front-main/l10n.yaml",
            "SrrFrr-App-Front-main/.gitignore",
            "SrrFrr-App-Front-main/README.md",
        ],
    ),
    (
        "chore(frontend): configure Android and iOS platforms",
        [
            "SrrFrr-App-Front-main/android",
            "SrrFrr-App-Front-main/ios",
        ],
    ),
    (
        "feat(frontend): add assets, localization and app shell",
        [
            "SrrFrr-App-Front-main/assets",
            "SrrFrr-App-Front-main/l10n",
            "SrrFrr-App-Front-main/lib/l10n",
            "SrrFrr-App-Front-main/lib/app",
            "SrrFrr-App-Front-main/lib/config",
            "SrrFrr-App-Front-main/lib/main.dart",
        ],
    ),
    (
        "feat(frontend): add core services and shared layer",
        [
            "SrrFrr-App-Front-main/lib/core",
            "SrrFrr-App-Front-main/lib/shared",
        ],
    ),
    (
        "feat(frontend): implement authentication flow",
        ["SrrFrr-App-Front-main/lib/features/auth"],
    ),
    (
        "feat(frontend): implement passenger booking experience",
        ["SrrFrr-App-Front-main/lib/features/passenger"],
    ),
    (
        "feat(frontend): implement driver registration and dashboard",
        ["SrrFrr-App-Front-main/lib/features/driver"],
    ),
    (
        "feat(frontend): add live ride tracking UI",
        ["SrrFrr-App-Front-main/lib/features/ride_tracking"],
    ),
    (
        "feat(frontend): add ride history and filters",
        ["SrrFrr-App-Front-main/lib/features/ride_history"],
    ),
    (
        "feat(frontend): implement wallet and recharge flows",
        ["SrrFrr-App-Front-main/lib/features/wallet"],
    ),
    (
        "feat(frontend): add driver subscription screens",
        ["SrrFrr-App-Front-main/lib/features/subscription"],
    ),
    (
        "feat(frontend): add in-app chat module",
        ["SrrFrr-App-Front-main/lib/features/chat"],
    ),
    (
        "feat(frontend): add push notifications center",
        ["SrrFrr-App-Front-main/lib/features/notifications"],
    ),
    (
        "feat(frontend): add loyalty and referral program",
        ["SrrFrr-App-Front-main/lib/features/loyalty_points"],
    ),
    (
        "feat(frontend): add profile and account settings",
        [
            "SrrFrr-App-Front-main/lib/features/profile",
            "SrrFrr-App-Front-main/lib/features/account_settings",
        ],
    ),
    (
        "feat(frontend): add support, FAQ and reclamations",
        ["SrrFrr-App-Front-main/lib/features/support"],
    ),
    (
        "test(frontend): add widget test scaffold",
        ["SrrFrr-App-Front-main/test"],
    ),
]

BRANCH_MARKERS = {
    "feature/auth-jwt": "feat(backend): implement authentication and OTP services",
    "feature/ride-realtime": "feat(backend): add realtime ride matching over WebSocket",
    "feature/wallet-subscription": "feat(backend): implement wallet, payments and subscriptions",
    "preprod": "ci(backend): add GitHub Actions pipeline and code quality rules",
}


def run(cmd, check=True):
    print("+", " ".join(cmd))
    result = subprocess.run(cmd, cwd=ROOT, text=True, capture_output=True)
    if check and result.returncode != 0:
        print(result.stdout)
        print(result.stderr, file=sys.stderr)
        raise SystemExit(result.returncode)
    return result


def exists(path: str) -> bool:
    return (ROOT / path).exists()


def git_commit(message: str, paths: list[str]) -> None:
    existing = [p for p in paths if exists(p)]
    if not existing:
        print(f"SKIP empty commit: {message}")
        return
    run(["git", "add", "--"] + existing)
    staged = run(["git", "diff", "--cached", "--name-only"], check=True)
    if not staged.stdout.strip():
        print(f"SKIP nothing staged: {message}")
        return
    run(["git", "commit", "-m", message])


def main() -> None:
    run(["git", "checkout", "--orphan", "rebuild-main"])
    run(["git", "rm", "-rf", "--cached", "."], check=False)

    commit_hashes: dict[str, str] = {}

    for message, paths in COMMITS:
        git_commit(message, paths)
        head = run(["git", "rev-parse", "HEAD"], check=True).stdout.strip()
        for branch, marker in BRANCH_MARKERS.items():
            if marker == message:
                commit_hashes[branch] = head

    # Catch-all for anything missed
    run(["git", "add", "-A"])
    leftover = run(["git", "diff", "--cached", "--name-only"], check=True).stdout.strip()
    if leftover:
        run(["git", "commit", "-m", "chore: add remaining project files"])

    final_head = run(["git", "rev-parse", "HEAD"], check=True).stdout.strip()
    commit_hashes.setdefault("preprod", final_head)

    run(["git", "branch", "-M", "main"])

    for branch, ref in commit_hashes.items():
        run(["git", "branch", branch, ref])

    print("\nCreated branches:")
    run(["git", "log", "--oneline", "--decorate", "-12"])
    run(["git", "branch", "-a"])


if __name__ == "__main__":
    main()
