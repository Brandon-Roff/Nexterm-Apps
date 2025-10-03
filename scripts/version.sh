#!/bin/bash
# Version management script for Nexterm Apps

CURRENT_VERSION=$(cat .version 2>/dev/null || echo "1.0")

show_help() {
    echo "🚀 Nexterm Apps Version Manager"
    echo "==============================="
    echo ""
    echo "Usage: $0 [command] [version]"
    echo ""
    echo "Commands:"
    echo "  current              Show current version"
    echo "  next                 Show next patch version"
    echo "  bump [patch|minor|major]  Bump version (default: patch)"
    echo "  set <version>        Set specific version"
    echo "  release              Bump version and trigger release"
    echo ""
    echo "Examples:"
    echo "  $0 current           # Shows: 1.0"
    echo "  $0 next             # Shows: 1.1"
    echo "  $0 bump             # 1.0 -> 1.1"
    echo "  $0 bump minor       # 1.0 -> 2.0"
    echo "  $0 bump major       # 1.0 -> 2.0"
    echo "  $0 set 1.5          # Sets version to 1.5"
    echo "  $0 release          # Bump version and commit"
}

get_version_parts() {
    local version=$1
    echo $version | sed 's/\./ /g'
}

bump_version() {
    local version=$1
    local type=${2:-patch}
    
    local parts=($(get_version_parts $version))
    local major=${parts[0]:-1}
    local minor=${parts[1]:-0}
    
    case $type in
        "patch"|"")
            minor=$((minor + 1))
            ;;
        "minor")
            major=$((major + 1))
            minor=0
            ;;
        "major")
            major=$((major + 1))
            minor=0
            ;;
        *)
            echo "❌ Invalid bump type: $type"
            echo "   Use: patch, minor, or major"
            exit 1
            ;;
    esac
    
    echo "$major.$minor"
}

case "$1" in
    "current"|"")
        echo "📍 Current version: $CURRENT_VERSION"
        ;;
    "next")
        NEXT_VERSION=$(bump_version $CURRENT_VERSION)
        echo "⏭️  Next version: $NEXT_VERSION"
        ;;
    "bump")
        NEW_VERSION=$(bump_version $CURRENT_VERSION $2)
        echo $NEW_VERSION > .version
        echo "🚀 Version bumped: $CURRENT_VERSION -> $NEW_VERSION"
        echo "📝 Version file updated (.version)"
        echo "💡 Commit and push to trigger release workflow"
        ;;
    "set")
        if [ -z "$2" ]; then
            echo "❌ Please specify version to set"
            echo "   Example: $0 set 1.5"
            exit 1
        fi
        echo $2 > .version
        echo "🎯 Version set to: $2"
        echo "📝 Version file updated (.version)"
        echo "💡 Commit and push to trigger release workflow"
        ;;
    "release")
        NEW_VERSION=$(bump_version $CURRENT_VERSION $2)
        echo $NEW_VERSION > .version
        
        echo "🚀 Creating release for version $NEW_VERSION..."
        
        # Add version file to git
        git add .version
        git commit -m "🔖 Bump version to $NEW_VERSION

Release Notes:
- Version bumped from $CURRENT_VERSION to $NEW_VERSION
- Automated release creation
- Updated application packages"
        
        echo "✅ Version committed: $NEW_VERSION"
        echo "🚀 Push to trigger release:"
        echo "   git push origin main"
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo "❌ Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac